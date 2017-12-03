import mt.MLib;
import mt.deepnight.Lib;

class CPoint {
	public var cx = 0;
	public var cy = 0;

	var centerX(get,never) : Float;
	var centerY(get,never) : Float;

	public function new(x,y) {
		cx = x;
		cy = y;
	}

	public function set(x,y) {
		cx = x;
		cy = y;
	}

	public function distEnt(e:Entity) {
		return Lib.distance(e.cx+e.xr,e.cy+e.yr,cx+0.5,cy+0.5);
	}

	inline function get_centerX() return (cx+0.5)*Const.GRID;
	inline function get_centerY() return (cy+0.5)*Const.GRID;
}