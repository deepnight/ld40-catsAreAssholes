import mt.deepnight.Lib;
import mt.MLib;

class Viewport extends mt.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var target(default,set) : Null<Entity>;

	public var x = 0.;
	public var y = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var wid(get,never) : Int;
	public var hei(get,never) : Int;

	public function new() {
		super(Game.ME);
	}

	inline function get_wid() {
		return MLib.ceil( Boot.ME.s2d.width / Const.SCALE );
	}

	inline function get_hei() {
		return MLib.ceil( Boot.ME.s2d.height / Const.SCALE );
	}

	function set_target(e:Entity) {
		target = e;
		x = target.footX;
		y = target.footY;
		return target;
	}

	override public function update() {
		super.update();

		if( target!=null ) {
			var a = Math.atan2(target.footY-y, target.footX-x);
			var d = mt.deepnight.Lib.distance(x, y, target.footX, target.footY);
			if( d>=20 ) {
				var s = 0.5 * MLib.fclamp(d/100,0,1);
				dx+=Math.cos(a)*s;
				dy+=Math.sin(a)*s;
			}
		}

		x+=dx;
		y+=dy;
		dx*=0.8;
		dy*=0.8;
		game.scroller.x = Std.int( -x + wid*0.5 );
		game.scroller.y = Std.int( -y + hei*0.5 );
	}
}