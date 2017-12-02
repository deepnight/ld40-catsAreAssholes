import mt.Process;
import mt.MLib;

class Game extends mt.Process {
	public static var ME : Game;
	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var level : Level;
	public var hero : en.Hero;

	public function new(ctx:h2d.Sprite) {
		super();
		ME = this;
		createRoot(ctx);
		root.scale(Const.SCALE);
		scroller = new h2d.Layers(root);
		vp = new Viewport();

		level = new Level(Home);
		hero = new en.Hero();
		vp.target = hero;
	}

	override public function onDispose() {
		super.onDispose();
	}

	override public function update() {
		super.update();

		// Updates
		for(e in Entity.ALL) {
			@:privateAccess e.dt = dt;
			if( !e.destroyed ) e.preUpdate();
			if( !e.destroyed ) e.update();
			if( !e.destroyed ) e.postUpdate();
		}

		// GC
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL.splice(i,1);
			else
				i++;
	}
}
