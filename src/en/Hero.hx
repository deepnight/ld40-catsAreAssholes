package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Hero extends Entity {
	var rollAng = 0.;

	public function new() {
		super(1,2);
		enableShadow();
		spr.anim.registerStateAnim("heroPostRoll",3, function() return cd.has("postRoll") && cd.getRatio("rolling")<=0.3 );
		spr.anim.registerStateAnim("heroRoll",2, 0.2, function() return cd.has("rolling") );
		spr.anim.registerStateAnim("heroWalk",1, 0.2, function() return MLib.fabs(dx)>=0.03 || MLib.fabs(dy)>=0.03 );
		spr.anim.registerStateAnim("heroIdle",0);
	}

	override public function update() {
		super.update();

		var spd = 0.03;

		if( !cd.has("locked") ) {
			// Movement
			if( Key.isDown(Key.RIGHT) ) {
				dir = 1;
				dx += dir*spd;
				rollAng = 0;
			}
			else if( Key.isDown(Key.LEFT) ) {
				dir = -1;
				dx += dir*spd;
				rollAng = 3.14;
			}

			if( Key.isDown(Key.UP) ) {
				dy -= spd;
				rollAng = -1.57;
			}
			else if( Key.isDown(Key.DOWN) ) {
				dy += spd;
				rollAng = 1.57;
			}

			// Roll
			if( Key.isDown(Key.SPACE) && !cd.has("rollLock") ) {
				cd.setS("rollLock",1.5);
				cd.setS("locked",0.6);
				cd.setS("postRoll",cd.getS("locked"));
				cd.setS("rolling",0.5);
			}
		}

		//if( dx!=0 || dy!=0 )
			//rollAng = Math.atan2(dy,dx);

		// Roll effect
		if( cd.has("rolling") ) {
			dx += Math.cos(rollAng)*0.08 * (0.3+0.7*cd.getRatio("rolling"));
			dy += Math.sin(rollAng)*0.08 * (0.3+0.7*cd.getRatio("rolling"));
		}

		// Assist movement near collisions
		if( dx<0 ) {
			// Left
			if( xr<=0.6 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr<=0.6 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}
		if( dx>0 ) {
			// Right
			if( xr>=0.4 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr>=0.4 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}
		if( dy<0 ) {
			// Up
			if( xr>=0.5 && yr<=0.4 && level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-1) ) dx+=spd*0.5;
			if( xr<=0.5 && yr<=0.4 && level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-1) ) dx-=spd*0.5;
		}
		if( dy>0 ) {
			// Down
			if( xr>=0.5 && yr>=0.7 && level.hasColl(cx,cy+1) && !level.hasColl(cx+1,cy+1) ) dx+=spd*0.5;
			if( xr<=0.5 && yr>=0.7 && level.hasColl(cx,cy+1) && !level.hasColl(cx-1,cy+1) ) dx-=spd*0.5;
		}
	}
}