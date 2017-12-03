import mt.Process;
import mt.MLib;

class Game extends mt.Process {
	public static var ME : Game;
	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var level : Level;
	public var hero : en.h.Grandma;
	public var side : en.h.Sidekick;
	public var fx : Fx;
	public var moneyMan : MoneyMan;

	public function new(ctx:h2d.Sprite) {
		super(Main.ME);

		ME = this;
		createRoot(ctx);
		//root.scale(Const.SCALE);
		scroller = new h2d.Layers(root);
		vp = new Viewport();
		fx = new Fx();
		//new ui.Stamina();
		new ui.Money();
		moneyMan = new MoneyMan();

		level = new Level(Home);
		level.attachEntities();

		vp.target = hero;
		vp.repos();
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	function gc() {
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL[i].dispose();
			else
				i++;
	}

	override public function update() {
		super.update();

		// Z sort
		Entity.ALL.sort( function(a,b) return Reflect.compare(a.z, b.z) );
		// Updates
		for(e in Entity.ALL) {
			scroller.over(e.spr);
			@:privateAccess e.dt = dt;
			if( !e.destroyed ) e.preUpdate();
			if( !e.destroyed ) e.update();
			if( !e.destroyed ) e.postUpdate();
		}
		gc();

		if( hxd.Key.isPressed(hxd.Key.R) )
			Main.ME.restartGame();
	}
}
