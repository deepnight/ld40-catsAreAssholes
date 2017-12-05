import mt.Process;
import mt.MLib;

class Main extends mt.Process {
	public static var BG = 0x0e0829;
	public static var ME : Main;
	public var console : Console;
	public var cached : h2d.CachedBitmap;
	var black : h2d.Bitmap;

	public function new() {
		super();

		ME = this;

		createRoot(Boot.ME.s2d);

		cached = new h2d.CachedBitmap(root, 1,1);
		cached.scaleX = cached.scaleY = Const.SCALE;

		#if debug
		hxd.Res.initLocal();
		hxd.res.Resource.LIVE_UPDATE = true;
		#else
		hxd.Res.initEmbed();
		#end

		Assets.init();
		Data.load( hxd.Res.data.entry.getText() );
		hxd.Timer.wantedFPS = Const.FPS;
		console = new Console();

		#if debug
		hxd.Res.data.watch( function() {
			delayer.cancelById("reload");
			delayer.addS("reload", function() {
				trace("reloaded");
				Data.load( hxd.Res.data.entry.getBytes().toString() );
				restartGame();
			},1);
		});
		#end

		black = new h2d.Bitmap(h2d.Tile.fromColor(BG,1,1), root);
		black.visible = false;

		#if debug
		restartGame();
		#else
		new ui.Title();
		#end

		onResize();
	}

	var presses : Map<Int,Bool>;
	public function keyPressed(k:Int) {
		if( console.isActive() )
			return false;

		if( presses==null )
			presses = new Map();

		if( presses.exists(k) )
			return false;

		presses.set(k, true);
		return hxd.Key.isDown(k);
	}

	public function setBlack(on:Bool, ?cb:Void->Void) {
		if( on ) {
			black.visible = true;
			tw.createS(black.alpha, 0>1, 0.6).onEnd = function() {
				if( cb!=null )
					cb();
			}
		}
		else {
			tw.createS(black.alpha, 0, 0.3).onEnd = function() {
				black.visible = false;
				if( cb!=null )
					cb();
			}
		}

	}

	override public function onResize() {
		super.onResize();
		cached.width = MLib.ceil(Boot.ME.s2d.width/cached.scaleX);
		cached.height = MLib.ceil(Boot.ME.s2d.height/cached.scaleY);
		black.scaleX = Boot.ME.s2d.width;
		black.scaleY = Boot.ME.s2d.height;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	public function restartGame() {
		if( ui.ShopWindow.ME!=null )
			ui.ShopWindow.ME.destroy();

		if( Game.ME!=null ) {
			setBlack(true, function() {
				Game.ME.destroy();
				delayer.addS(function() {
					new Game( new h2d.Sprite(cached) );
					tw.createS(Game.ME.root.alpha, 0>1, 0.4);
					setBlack(false);
				},0.5);
			});
		}
		else {
			new Game( new h2d.Sprite(cached) );
			tw.createS(Game.ME.root.alpha, 0>1, 0.4);
			setBlack(false);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		root.over(black);

		for(k in presses.keys())
			if( !hxd.Key.isDown(k) )
				presses.remove(k);
	}


	override function update() {
		super.update();

		if( keyPressed(hxd.Key.M) )
			mt.deepnight.Sfx.toggleMuteGroup(1);
	}
}
