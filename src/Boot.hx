import mt.MLib;
import hxd.Key;

class Boot extends hxd.App {
	public static var ME : Boot;
	var accu = 0.;
	var speed = 1.;

	// Boot
	static function main() {
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;

		engine.backgroundColor = 0xff<<24|0x0e0828;
		onResize();
#if hl
		@:privateAccess hxd.Stage.getInstance().window.vsync = true;
		@:privateAccess hxd.Stage.getInstance().window.displayMode = Borderless;
#end
		new Main();
	}

	override function onResize() {
		super.onResize();
		mt.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);

		#if debug
		if( !Console.ME.isActive() ) {
			if( Key.isPressed(Key.NUMPAD_SUB) )
				speed = speed==1 ? 0.35 : speed==0.35 ? 0.1 : 1;

			if( Key.isDown(Key.NUMPAD_ADD) )
				speed = 15;
			else if( speed>1 )
				speed = 1;
		}
		#end

		accu+=dt*speed;
		mt.heaps.slib.SpriteLib.DT = dt*speed;
		while( accu>=1 ) {
			mt.Process.updateAll(1);
			accu--;
		}
	}
}

