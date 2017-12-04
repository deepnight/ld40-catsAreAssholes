package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Coin extends Entity {
	public static var ALL : Array<Coin> = [];

	public var value : Int;
	var grabDist = 7;

	public function new(v:Int, x,y) {
		super(x,y);
		xr = rnd(0.2,0.8);
		yr = rnd(0.2,0.8);
		ALL.push(this);
		value = v;
		radius = Const.GRID*0.2;
		footOffsetY = 2;
		bounceFrict = 0.97;
		frict = 0.9;
		gravity*=0.8;
		enableShadow(0.5);
		weight = 0.1;
		zPrio = -99;

		altitude = rnd(5,10);
		jump(rnd(0.4,0.7));
		dx = rnd(0,0.1,true);
		dy = rnd(0,0.1,true);

		cd.setS("lock", rnd(0.4,0.8));
		spr.anim.playAndLoop(v>1?"coin":"scoin").setSpeed(rnd(0.1,0.2)).unsync();
		cd.setS("alive", 15);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function hasCircCollWith(e:Entity) {
		return super.hasCircCollWith(e) && e.is(Coin);
	}

	override public function postUpdate() {
		super.postUpdate();
		var a = MLib.fclamp(1-altitude/10,0,1);
		shadow.setScale(0.2 + 0.3*a);
		shadow.y+=1;
	}

	override public function update() {
		super.update();

		var magnet = false;
		var d = distCase(hero);
		if( !cd.has("lock") && d<=grabDist && ( sightCheck(hero) || level.hasColl(cx,cy) ) ) {
			if( !cd.hasSetS("magnetBounce",3) )
				jump(rnd(0.4,0.7));
			hasColl = false;
			magnet = true;
			var a = angTo(hero);
			var s = 0.04 * ( 0.1 + 0.9 * (1-d/grabDist) );
			dx+=Math.cos(a)*s;
			dy+=Math.sin(a)*s;
			if( d<=0.45 ) {
				hero.money+=value;
				ui.Money.ME.blink();
				destroy();
			}
		}
		else
			hasColl = true;

		if( magnet ) {
			spr.alpha = 1;
		}
		else {
			if( !cd.has("alive") ) {
				destroy();
				return;
			}

			if( cd.getS("alive")<=1 && !cd.hasSetS("blink",0.06) )
				spr.alpha = spr.alpha==0.6 ? 0 : 0.6;
			else if( cd.getS("alive")>1 && cd.getS("alive")<=3 && !cd.hasSetS("blink",0.09) )
				spr.alpha = spr.alpha==1 ? 0.3 : 1;
		}
	}
}