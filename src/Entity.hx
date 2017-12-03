import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var hero(get,never) : en.h.Grandma; inline function get_hero() return Game.ME.hero;
	public var side(get,never) : en.h.Sidekick; inline function get_side() return Game.ME.side;
	public var destroyed(default,null) = false;
	public var cd : mt.Cooldown;

	public var spr : HSprite;
	public var shadow : Null<HSprite>;
	var debug : Null<h2d.Graphics>;
	var emote : Null<HSprite>;
	var label : Null<h2d.Text>;
	var dt : Float;
	public var zPrio = 0.;

	public var uid : Int;
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.7;
	public var bounceFrict = 0.7;
	public var gravity = 0.2;
	public var weight = 1.;
	public var radius : Float;
	public var altitude = 0.;
	public var dalt = 0.;
	public var dir(default,set) = 1;

	public var z(get,never) : Float; inline function get_z() return footY+zPrio;
	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID-5+footOffsetY;
	public var onGround(get,never) : Bool; inline function get_onGround() return altitude==0 && dalt==0;
	var footOffsetY = 0;

	private function new(x,y) {
		uid = Const.UNIQ++;
		ALL.push(this);

		cd = new mt.Cooldown(Const.FPS);
		radius = Const.GRID*0.6;
		setPosCase(x,y);

		spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		game.scroller.add(spr, Const.DP_HERO);
		spr.setCenterRatio(0.5,1);
	}

	public function enableShadow(?scale=1.0) {
		if( shadow!=null )
			shadow.remove();
		shadow = Assets.gameElements.h_get("charShadow",0, 0.5,0.5);
		game.scroller.add(shadow, Const.DP_BG);
		shadow.scaleX = scale;
		shadow.alpha = 0.2;
	}

	public function jump(pow:Float) {
		dalt = 4*pow;
		altitude++;
	}

	function clearSay() {
		if( emote!=null ) {
			emote.remove();
			emote = null;
		}
	}

	public function say(id:String, ?sec=2.0) {
		clearSay();
		emote = Assets.gameElements.h_get(id,0, 0.5,1);
		game.scroller.add(emote, Const.DP_UI);
		cd.setS("saying",sec);
	}

	public static function countNearby(?except:Entity, x,y, d) {
		var n = 0;
		for(e in ALL)
			if( e!=except && Lib.distanceSqr(e.cx,e.cy,x,y)<=d*d )
				n++;
		return n;
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

	public function setLabel(?str:String, ?c=0xFFFFFF) {
		if( str==null && label!=null ) {
			label.remove();
			label = null;
		}
		if( str!=null ) {
			if( label==null ) {
				label = new h2d.Text(Assets.font);
				game.scroller.add(label, Const.DP_UI);
			}
			label.text = str;
			label.textColor = c;
		}
	}

	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return Lib.prettyFloat(v,p);

	public inline function distCase(e:Entity) {
		return Lib.distance(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	}

	public inline function distPx(e:Entity) {
		return Lib.distance(footX, footY, e.footX, e.footY);
	}

	function canSeeThrough(x,y) return !level.hasColl(x,y);

	public inline function sightCheck(e:Entity) {
		return mt.deepnight.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
	}

	public inline function sightCheckCase(x,y) {
		return mt.deepnight.Bresenham.checkThinLine(cx, cy, x, y, canSeeThrough);
	}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function angTo(e:Entity) return Math.atan2(e.footY-footY, e.footX-footX);
	public inline function dirTo(e:Entity) return e.footX<=footX ? -1 : 1;
	public inline function lookAt(e:Entity) dir = dirTo(e);
	public inline function isLookingAt(e:Entity) return dirTo(e)==dir;

	public inline function destroy() {
		trace(this+" destroyed");
		destroyed = true;
	}

	public function is<T:Entity>(c:Class<T>) return Std.is(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.instance(this, c);

	public function dispose() {
		ALL.remove(this);
		cd.destroy(); cd = null;
		spr.remove(); spr = null;
		if( shadow!=null )
			shadow.remove();
		if( label!=null )
			label.remove();
		if( debug!=null )
			debug.remove();
	}

	public function preUpdate() {
		cd.update(dt);
	}

	public function postUpdate() {
		spr.x = (cx+xr)*Const.GRID;
		spr.y = (cy+yr)*Const.GRID - altitude;
		//spr.x = Std.int((cx+xr)*Const.GRID);
		//spr.y = Std.int((cy+yr)*Const.GRID);
		spr.scaleX = dir;

		if( shadow!=null )
			shadow.setPos(spr.x, (cy+yr)*Const.GRID-2);

		if( label!=null )
			label.setPos(footX-label.textWidth*0.5, footY+2);

		if( emote!=null ) {
			emote.setPos(footX, footY-20);
			if( !cd.has("saying") ) {
				emote.alpha-=0.03;
				if( emote.alpha<=0 )
					clearSay();
			}

		}

		if( Console.ME.has("bounds") ) {
			if( debug==null ) {
				debug = new h2d.Graphics();
				game.scroller.add(debug, Const.DP_UI);
			}
			if( !cd.hasSetS("debugRedraw",1) ) {
				debug.beginFill(0xFFFF00,0.3);
				debug.lineStyle(1,0xFFFF00,0.7);
				debug.drawCircle(0,0,radius);
			}
			debug.setPos(footX, footY);
		}
		if( !Console.ME.has("bounds") && debug!=null ) {
			debug.remove();
			debug = null;
		}
	}

	function hasCircColl() {
		return !destroyed && weight>=0 && !cd.has("rolling") && altitude<=5;
	}

	function hasCircCollWith(e:Entity) {
		return true;
	}

	function onTouch(e:Entity) { }
	function onBounce(pow:Float) {}
	function onTouchWallX() {
		dx*=0.5;
	}
	function onTouchWallY() {
		dy*=0.5;
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

						var r = e.weight==weight ? 0.5 : e.weight / (weight+e.weight);
						if( r<=0.1 ) r = 0;
						dx-=Math.cos(a)*repel * r;
						dy-=Math.sin(a)*repel * r;

						var r = e.weight==weight ? 0.5 : weight / (weight+e.weight);
						if( r<=0.1 ) r = 0;
						e.dx+=Math.cos(a)*repel * r;
						e.dy+=Math.sin(a)*repel * r;

						onTouch(e);
						e.onTouch(this);
					}
				}

		// X
		xr+=dx;
		if( xr>1 && level.hasColl(cx+1,cy) ) {
			xr = 1;
			dx-=0.05;
			onTouchWallX();
		}
		if( xr>=0.8 && level.hasColl(cx+1,cy) ) {
			dx-=0.03;
		}
		if( xr<0 && level.hasColl(cx-1,cy) ) {
			xr = 0;
			dx+=0.05;
			onTouchWallX();
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
			onTouchWallY();
		}
		if( yr<0.1 && level.hasColl(cx,cy-1) ) {
			yr = 0.1;
			onTouchWallY();
		}
		dy*=frict;
		while( yr>1 ) { yr--; cy++; }
		while( yr<0 ) { yr++; cy--; }
		if( MLib.fabs(dy)<=0.001 ) dy = 0;

		// Gravity
		if( altitude>0 || dalt!=0 ) {
			dalt+=-gravity;
			altitude+=dalt;
			dalt*=0.95;
			if( altitude<=0 ) {
				if( MLib.fabs(dalt)<=0.1 )
					dalt = 0;
				else {
					dalt = MLib.fabs(dalt)*bounceFrict;
					onBounce( MLib.fclamp(MLib.fabs(dalt)/1.6, 0, 1) );
				}
				altitude = 0;
			}
		}
	}
}