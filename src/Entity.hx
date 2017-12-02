import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;
	public var cd : mt.Cooldown;

	public var spr : HSprite;
	public var shadow : Null<HSprite>;
	var dt : Float;

	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.7;
	public var weight = 1.;
	public var radius : Float;
	public var dir(default,set) = 1;

	public var z(get,never) : Float; inline function get_z() return footY;
	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;

	private function new(x,y) {
		ALL.push(this);

		cd = new mt.Cooldown(Const.FPS);
		radius = Const.GRID*0.4;
		setPosCase(x,y);

		spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		game.scroller.add(spr, Const.DP_HERO);
		spr.setCenterRatio(0.5,1);
	}

	public function enableShadow() {
		if( shadow!=null )
			shadow.remove();
		shadow = Assets.gameElements.h_get("charShadow",0, 0.5,0.5);
		game.scroller.add(shadow, Const.DP_BG);
		shadow.alpha = 0.2;
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

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p) return Lib.prettyFloat(v,p);

	public inline function distCase(e:Entity) {
		return Lib.distance(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	}

	public inline function distPx(e:Entity) {
		return Lib.distance(footX, footY, e.footX, e.footY);
	}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function destroy() {
		destroyed = true;
	}

	public function is<T>(c:Class<T>) return Std.is(this, c);

	public function dispose() {
		ALL.remove(this);
		cd.destroy(); cd = null;
		spr.remove(); spr = null;
		if( shadow!=null )
			shadow.remove();
	}

	public function preUpdate() {
		cd.update(dt);
	}

	public function postUpdate() {
		spr.x = (cx+xr)*Const.GRID;
		spr.y = (cy+yr)*Const.GRID;
		//spr.x = Std.int((cx+xr)*Const.GRID);
		//spr.y = Std.int((cy+yr)*Const.GRID);
		spr.scaleX = dir;
		shadow.setPos(spr.x, spr.y-1);
	}

	function hasCircColl() {
		return !destroyed && weight>=0 && !cd.has("rolling");
	}

	function hasCircCollWith(e:Entity) {
		return true;
	}

	public function update() {
		// Circular collisions
		if( hasCircColl() )
			for(e in ALL)
				if( e!=this && e.hasCircColl() && hasCircCollWith(e) ) {
					var d = distPx(e);
					if( d<=radius+e.radius ) {
						var repel = 0.05;
						var a = Math.atan2(e.footY-footY, e.footX-footX);

						var r = e.weight / (weight+e.weight);
						if( r<=0.1 ) r = 0;
						dx-=Math.cos(a)*repel * r;
						dy-=Math.sin(a)*repel * r;

						r = weight / (weight+e.weight);
						if( r<=0.1 ) r = 0;
						e.dx+=Math.cos(a)*repel * weight / (weight+e.weight);
						e.dy+=Math.sin(a)*repel * weight / (weight+e.weight);
					}
				}

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
		if( MLib.fabs(dx)<=0.001 ) dx = 0;

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
		if( MLib.fabs(dy)<=0.001 ) dy = 0;
	}
}