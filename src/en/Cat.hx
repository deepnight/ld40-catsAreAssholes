package en;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;
import mt.deepnight.Lib;
import en.inter.FoodTray;

enum Job {
	Wait;
	Follow(e:Entity);
	Fight(e:Entity, ?reason:String);
	Lick;
	Eat(e:en.inter.FoodTray, ?done:Bool);
	Shit;
	Play(e:Entity);
}

class Cat extends Entity {
	public static var ALL : Array<Cat> = [];

	var job : Job;
	var jobDurationS = 0.;
	var ang = 0.;
	var dashAng = 0.;
	var shitStock = 0;
	var target : Null<CPoint>;
	var path : Null<mt.deepnight.PathFinder.Path>;
	var pathEnd : Null<{ x:Int, y:Int }>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		path = null;
		radius = Const.GRID*0.4;

		enableShadow();

		spr.anim.registerStateAnim("bcatFearJump",21, function() return altitude>1 && cd.has("fear"));
		spr.anim.registerStateAnim("bcatFear",20, function() return cd.has("fear"));

		spr.anim.registerStateAnim("bcatShit",10, 0.2, function() return cd.has("shitting"));

		spr.anim.registerStateAnim("bcatDash",11, 0.2, function() return cd.has("dashing"));
		spr.anim.registerStateAnim("bcatCharge",10, 0.2, function() return cd.has("dashCharge"));

		spr.anim.registerStateAnim("bcatEat",10, 0.2, function() return cd.has("eating"));

		spr.anim.registerStateAnim("bcatLickLookBack",12, function() return atTarget() && job==Lick && cd.has("stareBack"));
		spr.anim.registerStateAnim("bcatLickLook",11, function() return atTarget() && job==Lick && cd.has("stare"));
		spr.anim.registerStateAnim("bcatLick",10, 0.15, function() return atTarget() && job==Lick);

		spr.anim.registerStateAnim("bcatAngryWalk",4, 0.25, function() return isAngry() && ( MLib.fabs(dx)>0 || MLib.fabs(dy)>0 ) );
		spr.anim.registerStateAnim("bcatWalk",3, 0.2, function() return MLib.fabs(dx)>0 || MLib.fabs(dy)>0 );

		spr.anim.registerStateAnim("bcatFall",15, function() return altitude>=3);
		spr.anim.registerStateAnim("bcatObserve",2, 0.5, function() return cd.has("observing"));
		spr.anim.registerStateAnim("bcatIdleRecent",1, function() return cd.has("recentWalk"));
		spr.anim.registerStateAnim("bcatIdleAngry",0, function() return isAngry());
		spr.anim.registerStateAnim("bcatIdle",0, function() return !isAngry());

		spr.lib.defineAnim("bcatObserve", "0(10),1,2(16),1");
		spr.lib.defineAnim("bcatShit", "0(2),1,2(3),1");
		spr.lib.defineAnim("bcatDash", "0(2),1");
		spr.lib.defineAnim("bcatEat", "0(2),1,0, 1,2, 1,2, 1,2(2)");
		spr.lib.defineAnim("bcatLick", "0-2(1), 3(2)");

		shitStock = irnd(0,2);
		startWait();
		cd.setS("love", rnd(15,40));
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function hasCircCollWith(e:Entity) {
		if( e.destroyed ) return false;
		if( !e.is(Cat) || cd.has("dashing") || e.cd.has("dashing") ) return true;
		return mt.deepnight.Lib.angularDistanceRad(getMoveAng(), e.getMoveAng())<=0.7;
	}

	function get_pathEnd() {
		if( path==null )
			return null;
		else
			return path[path.length-1];
	}

	inline function atTarget() {
		return target==null || cx==target.cx && cy==target.cy;
	}




	function startRandom() {
		//startPlay(); return; // HACK

		var rlist = new mt.RandList();
		rlist.add( startShit, 5*shitStock );
		rlist.add( startEat, 19-4*shitStock );
		rlist.add( startHeroFollow, 2 );
		rlist.add( startLick, 4 );
		rlist.add( startPlay, 3 );
		rlist.add( startWait.bind(), 3 );
		rlist.add( startCatAttack.bind(), 2 );
		if( !rlist.draw()() )
			startWait(1);
	}

	function startJob(j:Job, d:Float) {
		stop();
		job = j;
		jobDurationS = d;
	}

	function startEat() {
		var e = FoodTray.pickOne();
		if( e==null )
			return startHeroAttack("eReqFood");
		else
			startJob( Eat(e), rnd(5,8) );
		return true;
	}

	public function startCatAttack(?e:Cat) {
		if( cd.hasSetS("atkLimit", 15) )
			return false;

		if( e!=null )
			startJob( Fight(e), rnd(5,6) );
		else {
			var dh = new DecisionHelper(ALL);
			dh.remove( function(e) return e==this || e.destroyed );
			dh.score( function(e) return sightCheck(e) ? 5 : 0 );
			dh.score( function(e) return -distCase(e) );
			var e = dh.getBest();
			if( e!=null ) {
				startJob( Fight(e), rnd(8,12) );
				jump(1);
				cd.setS("lock", 1);
			}
			else
				return false;
		}

		return true;
	}

	function startHeroAttack(r:String) {
		say(r, 2);
		cd.setS("lock", rnd(1.5,2));
		lookAt(game.hero);
		startJob( Fight(hero,r), 999 );
		return true;
	}

	function startPlay() {
		var targets = Entity.ALL.filter( function(e) return e.is(en.inter.ItemDrop) || e.is(Furn) );
		var e = targets[Std.random(targets.length)];
		startJob(Play(e), rnd(5,7));
		return true;
	}

	function startWait(?t:Float) {
		var dh = new DecisionHelper( mt.deepnight.Bresenham.getDisc(cx,cy, 2) );
		dh.remove( function(pt) return level.hasColl(pt.x, pt.y) );
		dh.score( function(pt) return -Lib.distance(cx,cy,pt.x,pt.y) );
		dh.score( function(pt) return Entity.countNearby(pt.x,pt.y, 1)==0 ? 3 : 0 );
		var pt = dh.getBest();
		if( pt!=null )
			goto(pt.x, pt.y);
		startJob( Wait, t!=null ? t : rnd(2,5) );
		return true;
	}

	public function startHeroFollow() {
		startJob( Follow(hero), rnd(7,10) );
		return true;
	}

	function startLick() {
		var dh = new DecisionHelper( mt.deepnight.Bresenham.getDisc(cx,cy, 6) );
		dh.remove( function(pt) return level.hasColl(pt.x, pt.y) );
		dh.score( function(pt) return Lib.distance(cx,cy,pt.x,pt.y) );
		dh.score( function(pt) return sightCheckCase(pt.x,pt.y) ? 0 : -3 );
		dh.score( function(pt) return Lib.distance(cx,cy, pt.x,pt.y)<=3 ? -1 : 0 );
		dh.score( function(pt) return Entity.countNearby(pt.x,pt.y, 2)==0 ? 3 : 0 );

		var pt = dh.getBest();
		startJob( Lick, rnd(3,8) );
		goto(pt.x, pt.y);
		return true;
	}

	function startShit() {
		if( shitStock<=0 )
			return false;

		var all = en.inter.Litter.ALL.filter( function(e) return !e.isFull() );
		//var all = en.inter.Litter.ALL.filter( function(e) return !sightCheck(e) || !e.isFull() );
		if( all.length!=0 ) {
			var e = all[Std.random(all.length)];
			startJob(Shit, rnd(1.5,2));
			goto(e.cx, e.cy);
			return true;
		}
		else {
			// Shit on the ground
			var dh = new DecisionHelper( mt.deepnight.Bresenham.getDisc(cx,cy, 8) );
			dh.remove( function(pt) return level.hasColl(pt.x, pt.y) );
			dh.score( function(pt) return Lib.distance(cx,cy,pt.x,pt.y) );
			dh.score( function(pt) return sightCheckCase(pt.x,pt.y) ? 0 : -3 );
			dh.score( function(pt) return Lib.distance(cx,cy, pt.x,pt.y)<=3 ? -1 : 0 );
			dh.score( function(pt) return rnd(0,2) );
			dh.score( function(pt) return Entity.countNearby(this, pt.x,pt.y, 2)==0 ? 3 : 0 );

			var pt = dh.getBest();
			startJob( Shit, rnd(1.5,2.5) );
			goto(pt.x, pt.y);
			return true;
		}
	}



	public function flee(e:Entity) {
		var dh = new DecisionHelper( mt.deepnight.Bresenham.getDisc(cx,cy, 10) );
		dh.remove( function(pt) return level.hasColl(pt.x, pt.y) );
		dh.score( function(pt) return Lib.distance(e.cx,e.cy,pt.x,pt.y) );
		dh.score( function(pt) return !e.sightCheckCase(pt.x,pt.y) ? 2 : 0 );
		dh.score( function(pt) return rnd(0,1) );

		cd.setS("fleeing", 2);

		var pt = dh.getBest();
		startJob( Lick, rnd(5,6) );
		goto(pt.x, pt.y);
		return true;
	}

	function onJobComplete() {
		switch( job ) {
			case Shit :
				var e = en.inter.Litter.ALL.filter( function(e) return distCase(e)<=1 && !e.isFull() )[0];
				cd.unset("shitting");
				jump(0.4);
				if( e!=null ) {
					// In box
					game.moneyMan.trigger(this, PoopLitter);
					e.addShit(shitStock);
				}
				else {
					var e = new en.inter.ItemDrop(Shit, cx,cy);
					e.xr = xr;
					e.yr = yr;
					e.dx = -dir*0.2;
					e.altitude = 3;
					e.dalt = 2;
					e.dy = -0.1;
				}
				shitStock = 0;
				cd.setS("lock", rnd(1,2));

			default :
		}
		startRandom();
	}

	function stop() {
		path = null;
		target = null;
	}

	function goto(x,y) {
		setTarget(x,y);
	}

	function setTarget(x,y) {
		if( target==null )
			target = new CPoint(x,y);
		else
			target.set(x,y);

	}

	function gotoNearby(e:Entity, minDist:Int, maxDist:Int) {
		var dh = new DecisionHelper( mt.deepnight.Bresenham.getDisc(e.cx,e.cy, maxDist) );
		dh.remove( function(pt) return level.hasColl(pt.x, pt.y) || !e.sightCheckCase(pt.x,pt.y) || Lib.distance(e.cx,e.cy,pt.x,pt.y)<=minDist );
		dh.score( function(pt) return -Lib.distance(e.cx,e.cy,pt.x,pt.y) );
		dh.score( function(pt) return rnd(0,2) );

		var pt = dh.getBest();
		if( pt!=null )
			setTarget(pt.x, pt.y);
		else
			setTarget(e.cx,e.cy);
	}

	override function onTouch(e:Entity) {
		super.onTouch(e);

		switch( job ) {
			case Play(pe) :
				// Touch the entity he is playing with
				if( pe==e && e.onGround )
					e.jump(rnd(0.6,1));
				if( pe==e && !cd.hasSetS("playKick",0.4) ) {
					var a = Math.atan2(e.footY-footY, e.footX-footX) + rnd(0,0.3,true);
					var s = rnd(0.1,0.3);
					e.dx+=Math.cos(a)*s;
					e.dy+=Math.sin(a)*s;
					e.jump(rnd(0.3,0.5));
				}
			default :
		}

		if( cd.has("dashing") && !e.cd.hasSetS("hit"+uid,1.5) ) {
			switch( job ) {
				case Fight(te) :
					if( te.is(Hero) && e.is(Hero) ) {
						if( e.onGround )
							e.jump(0.5);
					}
					if( te.is(Cat) && e.is(Cat) ) {
						var e : Cat = Std.instance(e,Cat);
						e.flee(this);
						e.cd.setS("lock", rnd(1.2,1.6));
						e.cd.setS("fear", e.cd.getS("lock"));
						e.jump(rnd(1,1.7));
						game.moneyMan.trigger(this, FightCat);

						var a = Math.atan2(e.footY-footY, e.footX-footX);
						e.dx+=Math.cos(a)*0.3;
						e.dy+=Math.sin(a)*0.3;

						startWait(2);
					}

				default :
			}
		}
	}

	inline function isAngry() {
		return job!=null && job.getIndex()==Type.enumIndex(Fight(null));

	}

	override public function update() {
		super.update();

		// Interrupt fight
		switch( job ) {
			case Fight(e,r) :
				switch( r ) {
					case "eReqFood" :
						for(e in en.inter.FoodTray.ALL)
							if( !e.isEmpty() && sightCheck(e) ) {
								clearSay();
								startEat();
								break;
							}

					case "eReqShit" :
						for(e in en.inter.Litter.ALL)
							if( !e.isFull() && sightCheck(e) ) {
								clearSay();
								startWait(1);
								break;
							}
				}
			default :
		}


		// Job effects on paths
		switch( job ) {
			case Follow(e) :
				if( e.destroyed )
					startRandom();
				else {
					if( distCase(e)<=2 && sightCheck(e) ) {
						if( !cd.hasSetS("love",rnd(25,50)) ) {
							game.moneyMan.trigger(this, Love);
							say("eLove", 1);
						}
						stop();
					}
					else
						gotoNearby(e,1,3);
				}

			case Fight(e,r) :
				if( r!=null && distCase(e)<=6 )
					say(r, 2);

				if( e.destroyed )
					startRandom();
				else if( !cd.has("dashLock") && distCase(e)<=4 && sightCheck(e) ) {
					dashAng = Math.atan2(e.footY-footY, e.footX-footX);
					dx+=Math.cos(dashAng)*0.2;
					dy+=Math.sin(dashAng)*0.2;
					dir = dx>0 ? 1 : -1;
					cd.setS("dashLock", rnd(1.6,2));
					cd.setS("lock", rnd(1.5,3.5));
					cd.setS("dashCharge", 0.3, function() {
						cd.setS("dashing", 0.45);
					});
				}
				else if( distCase(e)<=3 )
					stop();
				else
					goto(e.cx, e.cy);

			case Eat(e) :
				goto(e.cx,e.cy);

			case Play(e) :
				if( e.destroyed )
					startWait(1);
				else {
					if( cd.has("observing") )
						lookAt(e);
					if( distCase(e)>3 )
						gotoNearby(e,1,2);
					else if( !cd.has("observeLock") ) {
						cd.setS("lock",1);
						cd.setS("observing", 1);
						cd.setS("observeLock", rnd(2,4));
						lookAt(e);
					}
					else if( atTarget() ) {
						if( !cd.hasSetS("playDash",0.3) ) {
							var a = angTo(e);
							dx+=Math.cos(a)*0.2;
							dy+=Math.sin(a)*0.2;
						}
						gotoNearby(e, 2,3);
					}
					else
						goto(e.cx,e.cy);
				}

			case Wait :
			case Shit :
			case Lick :
		}

		var spd = isAngry() || cd.has("fleeing") ? 0.05 : 0.03;

		// Dash movement
		if( cd.has("dashing") ) {
			switch( job ) {
				case Fight(e) :
					dashAng += Lib.angularSubstractionRad(Math.atan2(e.footY-footY, e.footX-footX), dashAng)*0.04;

				default :
			}
			dx+=Math.cos(dashAng)*0.08;
			dy+=Math.sin(dashAng)*0.08;
		}

		#if debug
		if( Console.ME.has("path") ) {
			if( target!=null )
				fx.markerCase(target.cx,target.cy,0x0080FF,true);
			if( path!=null )
				for(pt in path)
					fx.markerCase(pt.x,pt.y,true);
		}
		#end

		if( !cd.has("lock") && onGround ) {
			// Track target
			if( !atTarget() && target!=null ) {
				if( sightCheckCase(target.cx,target.cy) && target.distEnt(this)<=5 ) {
					// Target is on sight
					if( path!=null )
						path = null;
					var a = Math.atan2((target.cy+0.5)-(cy+yr), (target.cx+0.5)-(cx+xr));
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
								var a = Math.atan2((next.y+0.5)-(cy+yr), (next.x+0.5)-(cx+xr)) + rnd(0,0.2,true);
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
				case Shit : atTarget();
				case Eat(e, _) : distCase(e)<=1.8;
				case Fight(e) : distCase(e)<=1;
				case Play(e) : distCase(e)<=5 && sightCheck(e);
			}
			if( doingIt ) {
				// Job effect when doing them
				switch( job ) {
					case Eat(e,done) :
						if( !done ) {
							if( e.eat() ) {
								shitStock++;
								job = Eat(e,true);
							}
							else
								startEat();
						}
						cd.setS("eating",0.3);
						e.cd.setS("eating",0.3);
						lookAt(e);
					case Fight(e) :
					case Follow(_) :
					case Wait :
					case Lick : game.moneyMan.trigger(this, Lick);
					case Play(_) :
					case Shit : cd.setS("shitting", 0.3);
				}

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
			#if debug
			if( Console.ME.has("job") )
				setLabel(job+"("+doingIt+") "+pretty(jobDurationS)+"s");
			#end
		}

	}
}