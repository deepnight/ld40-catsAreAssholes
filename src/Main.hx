import mt.Process;
import mt.MLib;

class Main extends mt.Process {
	public static var ME : Main;
	public var console : Console;

	public function new() {
		super();

		ME = this;
		createRoot(Boot.ME.s2d);

		#if debug
		hxd.Res.initLocal();
		hxd.res.Resource.LIVE_UPDATE = true;
		#else
		hxd.Res.initEmbed( { compressSounds:true } );
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

		restartGame();
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	public function restartGame() {
		if( Game.ME!=null ) {
			tw.createS(Game.ME.root.alpha, 0, 0.5).end( function() {
				Game.ME.destroy();
				delayer.addF(function() {
					new Game( new h2d.Sprite(root) );
					tw.createS(Game.ME.root.alpha, 0>1, 0.4);
				},1);
			});
		}
		else {
			new Game( new h2d.Sprite(root) );
			tw.createS(Game.ME.root.alpha, 0>1, 0.4);
		}
	}
}
