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
		new Main();
		onResize();
	}

	override function onResize() {
		super.onResize();
		dn.Process.resizeAll();
	}

	override function update(dt:Float) {
		super.update(dt);

		var tmod = hxd.Timer.tmod;
		#if debug
		if( !Console.ME.isActive() ) {
			if( Key.isPressed(Key.NUMPAD_SUB) )
				speed = speed==1 ? 0.35 : speed==0.35 ? 0.1 : 1;

			if( Key.isPressed(Key.P) )
				speed = speed==0 ? 1 : 0;

			if( Key.isDown(Key.NUMPAD_ADD) )
				speed = 15;
			else if( speed>1 )
				speed = 1;
		}
		#end

		accu+=tmod*speed;
		dn.heaps.slib.SpriteLib.TMOD = tmod*speed;
		while( accu>=1 ) {
			dn.Process.updateAll(1);
			accu--;
		}
	}
}

