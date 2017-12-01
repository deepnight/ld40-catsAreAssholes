class Boot extends hxd.App {
	public static var ME : Boot;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0xff<<24|0x0;
		onResize();

		new Main();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);
		mt.Process.updateAll(dt);
	}
}

