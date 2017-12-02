package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;
import mt.deepnight.Lib;

class Cat extends Entity {
	public static var ALL : Array<Cat> = [];

	var ang = 0.;
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		enableShadow();
		spr.anim.registerStateAnim("heroPostRoll",3, function() return cd.has("postRoll") && cd.getRatio("rolling")<=0.3 );
		spr.anim.registerStateAnim("heroRoll",2, 0.2, function() return cd.has("rolling") );
		spr.anim.registerStateAnim("heroWalk",1, 0.2, function() return MLib.fabs(dx)>=0.03 || MLib.fabs(dy)>=0.03 );
		spr.anim.registerStateAnim("heroIdle",0);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function hasCircCollWith(e:Entity) {
		if( !e.is(Cat) ) return true;
		return mt.deepnight.Lib.angularDistanceRad(getMoveAng(), e.getMoveAng())<=0.7;
	}

	override public function update() {
		super.update();
		if( !cd.has("dir") ) {
			ang = irnd(0,3)*MLib.PIHALF;
			cd.setS("dir",rnd(0.5,2));
			dir = Math.cos(ang)>=0.1 ? 1 : Math.cos(ang)<=-0.1 ? -1 : dir;
		}
		var s = 0.015;
		dx+=Math.cos(ang)*s;
		dy+=Math.sin(ang)*s;
	}
}