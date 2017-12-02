package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;
import mt.deepnight.Lib;

enum Job {
	Wait;
	Follow(e:Entity);
	Lick;
}

class Cat extends Entity {
	public static var ALL : Array<Cat> = [];

	var job : Job;
	var jobDurationS = 0.;
	var ang = 0.;
	var target : CPoint;
	var path : Null<mt.deepnight.PathFinder.Path>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		path = null;
		target = new CPoint(cx,cy);

		enableShadow();
		spr.anim.registerStateAnim("bcatLickLookBack",12, function() return atTarget() && job==Lick && cd.has("stareBack"));
		spr.anim.registerStateAnim("bcatLickLook",11, function() return atTarget() && job==Lick && cd.has("stare"));
		spr.anim.registerStateAnim("bcatLick",10, 0.15, function() return atTarget() && job==Lick);

		spr.anim.registerStateAnim("bcatWalk",1, 0.2, function() return MLib.fabs(dx)>0 || MLib.fabs(dy)>0 );
		spr.anim.registerStateAnim("bcatIdleRecent",1, function() return cd.has("recentWalk"));
		spr.anim.registerStateAnim("bcatIdle",0);

		spr.lib.defineAnim("bcatLick", "0-2(1), 3(2)");

		startJob( Lick, 0.5 );
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function hasCircCollWith(e:Entity) {
		if( !e.is(Cat) ) return true;
		return mt.deepnight.Lib.angularDistanceRad(getMoveAng(), e.getMoveAng())<=0.7;
	}

	inline function atTarget() {
		return target!=null && cx==target.cx && cy==target.cy;
	}

	function startJob(j:Job, d:Float) {
		stop();
		job = j;
		jobDurationS = d;

		switch( job ) {
			case Lick :
			case Follow(_) :
			case Wait :
		}
	}

	function onJobComplete() {
		//switch( job ) {
			//case Lick : startJob( Follow(hero), rnd(5,8) );
			////case Follow(_) : startJob( Lick, rnd(5,8) );
			////case Wait : startJob( Lick );
			//default : startJob( Lick, rnd(5,8) );
		//}
	}

	function stop() {
		path = null;
		target.set(cx,cy);
	}

	function goto(x,y) {
		target.set(x,y);
	}

	override public function update() {
		super.update();

		// Special job effects
		switch( job ) {
			case Follow(e) :
				if( e.destroyed ) {
					job = Wait;
					stop();
				}
				else {
					if( distCase(e)<=3 && sightCheck(e) )
						stop();
					else
						goto(e.cx, e.cy);
				}

			case Wait :

			case Lick :
		}

		var spd = 0.03;

		// Track target
		if( !atTarget() ) {
			if( sightCheckCase(target.cx,target.cy) ) {
				// Target is on sight
				if( path!=null )
					path = null;
				var a = Math.atan2(target.cy-cy, target.cx-cx);
				dx += Math.cos(a)*spd;
				dy += Math.sin(a)*spd;
				dir = Math.cos(a)>=0.1 ? 1 : Math.cos(a)<=-0.1 ? -1 : dir;
				cd.setS("recentWalk", 1);
				cd.setS("pfLock", rnd(0.2,0.6));
			}
			else {
				// Find path
				if( path==null && !cd.has("pfLock") ) {
					path = level.pf.getPath( { x:cx, y:cy, } , { x:target.cx, y:target.cy } );
					path = level.pf.smooth(path);
				}

				// Follow path
				if( path!=null ) {
					if( path.length>0 ) {
						var next = path[0];
						if( cx==next.x && cy==next.y ) {
							path.shift();
							next = path[0];
							cd.setS("stareLock", rnd(0.5,1), true);
						}
						if( next!=null && ( cx!=next.x || cy!=next.y ) ) {
							var a = Math.atan2(next.y-cy, next.x-cx);
							dx += Math.cos(a)*spd;
							dy += Math.sin(a)*spd;
							dir = Math.cos(a)>=0.1 ? 1 : Math.cos(a)<=-0.1 ? -1 : dir;
							cd.setS("recentWalk", 1);
						}
					}

					if( !atTarget() && path.length==0 )
						path = null;
				}
			}
		}

		// Job update
		var doingIt = switch( job ) {
			case Follow(e) : distCase(e)<=6;
			case Lick, Wait : atTarget();
		}
		if( doingIt ) {
			jobDurationS-=1/Const.FPS;

			if( !cd.has("stareLock") ) {
				cd.setS("stare", rnd(0.5,0.7));
				if( Std.random(2)==0 )
					cd.setS("stareBack", cd.getS("stare"));
				cd.setS("stareLock", rnd(2,4));
			}

			if( jobDurationS<=0 )
				onJobComplete();
		}
		setLabel(doingIt+" "+pretty(jobDurationS)+"s");
	}
}