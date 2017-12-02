import mt.Process;
import mt.MLib;

class Game extends mt.Process {
	public static var ME : Game;
	public var level : Level;
	public var hero : en.Hero;

	public function new(ctx:h2d.Sprite) {
		super();
		ME = this;
		createRoot(ctx);
		root.scale(Const.SCALE);
		level = new Level(Home);
		hero = new en.Hero();
	}

	override public function onDispose() {
		super.onDispose();
	}

	override public function update() {
		super.update();

		// Updates
		for(e in Entity.ALL) {
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
