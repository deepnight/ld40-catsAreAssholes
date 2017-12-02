import mt.MLib;
import mt.heaps.slib.*;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;

	public var spr : HSprite;

	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.7;
	public var dir(default,set) = 1;

	private function new(x,y) {
		ALL.push(this);

		setPosCase(x,y);

		spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		game.root.add(spr, Const.DP_HERO);
		spr.setCenterRatio(0.5,1);
	}


	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
	}

	public inline function destroy() {
		destroyed = true;
	}

	public function dispose() {
		ALL.remove(this);
		spr.remove();
		spr = null;
	}

	public function preUpdate() {
	}

	public function postUpdate() {
		spr.setPos( (cx+xr)*Const.GRID, (cy+yr)*Const.GRID );
		spr.scaleX = dir;
	}

	public function update() {

		// X
		xr+=dx;
		if( xr>1 && level.hasColl(cx+1,cy) ) {
			xr = 1;
			dx*=0.5;
		}
		if( xr>=0.8 && level.hasColl(cx+1,cy) ) {
			dx-=0.03;
		}
		if( xr<0 && level.hasColl(cx-1,cy) ) {
			xr = 0;
			dx+=0.05;
			dx*=0.5;
		}
		if( xr<0.2 && level.hasColl(cx-1,cy) ) {
			dx+=0.03;
		}
		dx*=frict;
		while( xr>1 ) { xr--; cx++; }
		while( xr<0 ) { xr++; cx--; }

		// Y
		yr+=dy;
		if( yr>1 && level.hasColl(cx,cy+1) ) {
			yr = 1;
			dy*=0.5;
		}
		if( yr<0.1 && level.hasColl(cx,cy-1) ) {
			yr = 0.1;
			dy*=0.5;
		}
		dy*=frict;
		while( yr>1 ) { yr--; cy++; }
		while( yr<0 ) { yr++; cy--; }
	}
}