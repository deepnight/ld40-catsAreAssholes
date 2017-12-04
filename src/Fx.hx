import h2d.Sprite;
import mt.heaps.HParticle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.Tweenie;
import mt.MLib;


class Fx extends mt.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.gameElements.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_TOP);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.gameElements.tile);
		game.scroller.add(topAddSb, Const.DP_FX_TOP);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();

		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}


	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.gameElements.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, c, short);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerFree(x:Float, y:Float, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("star"), x,y);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		var tf = new h2d.Text(Assets.font, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.frict = 0.92;
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPos(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_TOP);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});

	}


	//function _isoPhysics(p:HParticle) {
	//}

	public function dirt(x:Float, y:Float, n:Int, c:UInt, c2:UInt) {
		for(i in 0...n) {
			var p = allocBgNormal(getTile("dirt"), x+rnd(0,6,true), y+rnd(0,4,true) );
			p.setFadeS(rnd(0.6,1), 0, rnd(3,5));
			p.colorize( Color.interpolateInt( Color.interpolateInt(c,c2,rnd(0,1)), 0x0, rnd(0,0.3)) );
			p.dx = rnd(0,1.5,true);
			p.dy = rnd(-4,-2);
			if( Std.random(8)==0 )
				p.dy *= 1.5;
			p.gy = rnd(0.1,0.3);
			p.frict = rnd(0.96,0.97);
			p.rotation = rnd(0,6.28);
			p.setScale(rnd(0.6,1.1,true));
			p.groundY = y + rnd(-20,30);
			p.dr = rnd(0.1,0.3,true);
			p.scaleMul = rnd(0.990,0.995);
			//p.onUpdate = _isoPhysics;
			p.bounceMul = 0.3;
			var n = irnd(2,3);
			p.onBounce = function() {
				p.dx*=0.7;
				p.dr*=0.5;
				if( --n<=0 ) {
					p.moveAwayFrom(x,y, rnd(0,0.5));
					p.gy = 0;
					p.scaleMul = rnd(0.999,1);
					p.dr = 0;
					p.groundY = null;
				}
			}
			p.lifeS = rnd(4,10);
		}
	}


	override function update() {
		super.update();
		pool.update(1);
	}
}