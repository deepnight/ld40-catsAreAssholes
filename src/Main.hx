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
				Game.ME.destroy();
				startGame();
			},1);
		});
		#end

		startGame();
	}

	function startGame() {
		new Game( new h2d.Sprite(root) );
	}
}
