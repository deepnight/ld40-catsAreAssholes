class Viewport extends dn.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var target(default,set) : Null<Entity>;

	public var x = 0.;
	public var y = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var wid(get,never) : Int;
	public var hei(get,never) : Int;
	public var screenWid(get,never) : Int;
	public var screenHei(get,never) : Int;

	public function new() {
		super(Game.ME);
	}

	inline function get_screenWid() return Boot.ME.s2d.width;
	inline function get_screenHei() return Boot.ME.s2d.height;

	inline function get_wid() {
		return M.ceil( Boot.ME.s2d.width / Const.SCALE );
	}

	inline function get_hei() {
		return M.ceil( Boot.ME.s2d.height / Const.SCALE );
	}

	function set_target(e:Entity) {
		target = e;
		return target;
	}

	public function repos() {
		if( target!=null ) {
			x = target.footX;
			y = target.footY;
		}
	}

	override public function update() {
		super.update();

		if( target!=null ) {
			var a = Math.atan2(target.footY-y, target.footX-x);
			var d = dn.M.dist(x, y, target.footX, target.footY);
			if( d>=20 ) {
				var s = 0.5 * M.fclamp(d/100,0,1);
				dx+=Math.cos(a)*s;
				dy+=Math.sin(a)*s;
			}
		}

		x+=dx;
		y+=dy;
		dx*=0.8;
		dy*=0.8;
		var prioCenter = 0.3;
		if( Console.ME.has("screen") ) {
			game.scroller.x = -level.wid*0.5*Const.GRID + wid*0.5;
			game.scroller.y = -level.hei*0.5*Const.GRID + hei*0.5;
		}
		else {
			game.scroller.x = Std.int( -(x+prioCenter*level.wid*0.5*Const.GRID)/(1+prioCenter) + wid*0.5 );
			game.scroller.y = Std.int( -(y+prioCenter*level.hei*0.5*Const.GRID)/(1+prioCenter) + hei*0.5 );
		}
	}
}