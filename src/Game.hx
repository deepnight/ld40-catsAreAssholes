import hxd.Pad;

class Game extends dn.Process {
	public static var ME : Game;
	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var level : Level;
	public var hero : en.h.Grandma;
	public var side : en.h.Sidekick;
	public var fx : Fx;
	public var moneyMan : MoneyMan;
	public var cm : dn.Cinematic;
	public var catIdx = 0;

	public var hudWrapper : h2d.Flow;
	public var ctrl : dn.heaps.Controller.ControllerAccess;

	public function new(ctx:h2d.Object) {
		super(Main.ME);

		ME = this;
		ctrl = Main.ME.ctrlMaster.createAccess("game");
		ctrl.setLeftDeadZone(0.15);
		createRoot(ctx);

		hudWrapper = new h2d.Flow();
		root.add(hudWrapper, Const.DP_TOP);
		hudWrapper.verticalAlign = Middle;
		hudWrapper.horizontalSpacing = 8;

		scroller = new h2d.Layers(root);
		vp = new Viewport();
		fx = new Fx();
		new ui.Money();
		new ui.Life();
		//new ui.Followers();
		moneyMan = new MoneyMan();
		new Tutorial();
		cm = new dn.Cinematic(Const.FPS);

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
		ctrl.dispose();
	}

	function gc() {
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL[i].dispose();
			else
				i++;
	}

	public inline function hasCinematic() {
		return !cm.isEmpty();
	}

	override function postUpdate() {
		super.postUpdate();
		hudWrapper.x = Std.int(vp.wid*0.5 - hudWrapper.outerWidth*0.5);
		hudWrapper.y = 16;
	}

	override public function update() {
		super.update();

		cm.update(tmod);

		// Z sort
		if( !cd.hasSetS("zsort",0.1) )
			Entity.ALL.sort( function(a,b) return Reflect.compare(a.z, b.z) );

		// Updates
		for(e in Entity.ALL) {
			scroller.over(e.spr);
			@:privateAccess e.dt = tmod;
			if( !e.destroyed ) e.preUpdate();
			if( !e.destroyed ) e.update();
			if( !e.destroyed ) e.postUpdate();
		}
		gc();

		if( Main.ME.keyPressed(hxd.Key.R) )
			Main.ME.restartGame();

		#if hl
		// Exit
		if( Main.ME.keyPressed(Key.ESCAPE) )
			if( !cd.hasSetS("exitWarn",3) )
				new ui.Message("Press ESCAPE again to exit.");
			else
				hxd.System.exit();
		#end

		Tutorial.ME.tryToStart("controls", "Use ARROWS or GamePad to move.");

		if( Tutorial.ME.hasDone("food") )
			Tutorial.ME.tryToStart("shop", "You should call your grandson Mark to help you here. Use the phone.");

		if( Tutorial.ME.hasDone("side") )
			Tutorial.ME.tryToStart("shop2", "Use the phone again to get more cats, or buy items!");
	}
}
