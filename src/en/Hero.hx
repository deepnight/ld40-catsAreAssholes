package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Hero extends Entity {
	public function new() {
		super(1,2);
		spr.set("ghost");
	}

	override public function update() {
		super.update();
		var spd = 0.03;
		if( Key.isDown(Key.RIGHT) ) {
			dir = 1;
			dx += dir*spd;
			if( xr>=0.6 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr>=0.6 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}
		else if( Key.isDown(Key.LEFT) ) {
			dir = -1;
			dx += dir*spd;
			if( xr<=0.4 && yr>=0.6 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy+1) ) dy+=spd*0.5;
			if( xr<=0.4 && yr<=0.7 && level.hasColl(cx+dir,cy) && !level.hasColl(cx+dir,cy-1) ) dy-=spd*0.5;
		}

		if( Key.isDown(Key.UP) ) {
			dy -= spd;
			if( xr>=0.6 && yr<=0.3 && level.hasColl(cx,cy-1) && !level.hasColl(cx+1,cy-1) ) dx+=spd*0.5;
			if( xr<=0.4 && yr<=0.3 && level.hasColl(cx,cy-1) && !level.hasColl(cx-1,cy-1) ) dx-=spd*0.5;
		}
		else if( Key.isDown(Key.DOWN) ) {
			dy += spd;
			if( xr>=0.5 && yr>=0.8 && level.hasColl(cx,cy+1) && !level.hasColl(cx+1,cy+1) ) dx+=spd*0.5;
			if( xr<=0.5 && yr>=0.8 && level.hasColl(cx,cy+1) && !level.hasColl(cx-1,cy+1) ) dx-=spd*0.5;
		}
	}
}