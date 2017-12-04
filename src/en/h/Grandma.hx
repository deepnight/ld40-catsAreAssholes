package en.h;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

class Grandma extends en.Hero {
	var rollAng = 0.;
	var focus : HSprite;

	public var life : Int;
	public var maxLife = 5;
	public var money = 50;
	public var followers = 0;

	public function new(x,y) {
		super(x,y);

		life = maxLife;
		weight = 2;

		#if debug
		money = 9999;
		#end

		spr.anim.registerStateAnim("heroDead",11, function() return isDead() );
		spr.anim.registerStateAnim("heroHit",10, function() return cd.has("recentHit") );

		spr.anim.registerStateAnim("heroPostRollEnd",9, function() return cd.has("rolling") && cd.getRatio("rolling")<0.2 );
		spr.anim.registerStateAnim("heroPostRoll",8, function() return cd.getRatio("rolling")>=0.2 && cd.getRatio("rolling")<0.5 );
		spr.anim.registerStateAnim("heroRoll",7, 0.17, function() return cd.getRatio("rolling")>=0.5 );

		spr.anim.registerStateAnim("heroWalk",2, 0.25, function() return cd.has("walking") );
		spr.anim.registerStateAnim("heroTalk",1,0.4, function() return cd.has("talking") );
		spr.anim.registerStateAnim("heroIdle",0, 0.6);

		spr.lib.defineAnim("heroTalk", "0,1,2(2),1,0,1,0,2,1(2),2,0,1(2),2,0,2");
		spr.lib.defineAnim("heroRoll", "0");
		spr.lib.defineAnim("heroWalk", "0(2),1,2,3,4(2),3,2,1");

		focus = Assets.gameElements.h_get("use",0, 0.5,0.5);
		focus.scaleY = -1;
		focus.visible = false;
		game.scroller.add(focus, Const.DP_UI);

		enableShadow(2);
	}

	override public function pick(itemUid:Int, i:Data.ItemKind) {
		super.pick(itemUid, i);
		Assets.SBANK.pick1(1);
	}

	override public function dropItem() {
		super.dropItem();
		Assets.SBANK.drop0(1);
	}

	override public function sayWords(str:String, ?c = 0xFFFFFF) {
		super.sayWords(str, c);
		cd.setS("talking", 1);
	}


	override public function emote(id:String, ?sec = 2.0) {
		super.emote(id, sec);
		cd.setS("talking",1);
	}
	override function clearWords(?immediate = false) {
		super.clearWords(immediate);
		cd.unset("talking");
	}

	public function gainFollowers(n:Int, ?major=true) {
		game.delayer.addS( function() {
			if( destroyed )
				return;
			followers += MLib.round(n*rnd(0.9,1.1)) ;
			//ui.Followers.ME.set(followers, major);
		}, rnd(0.9,1.3));
	}

	override function getThrowAng() {
		return rollAng;
	}

	override public function dispose() {
		super.dispose();
		focus.remove();
	}

	public function loseMoney(?source:Entity, v:Int) {
		(source==null?this:source).pop("-$"+v, 0xFF0000);
		money-=v;
		if( money<0 )
			money = 0;
		ui.Money.ME.set(money);
		ui.Money.ME.blink();
	}
	override function hasCircCollWith(e:Entity) {
		if( isDead() )
			return true;

		return super.hasCircCollWith(e);
	}

	override public function postUpdate() {
		super.postUpdate();
		ui.Money.ME.set(money);
		ui.Life.ME.set(life/maxLife);
		if( spr.anim.isPlaying("heroRoll") ) {
			spr.setCenterRatio(0.5,0.5);
			spr.rotate(0.9*dir);
			spr.y-=16;
		}
		else {
			spr.rotation = 0;
			spr.setCenterRatio(0.5,1);
		}

		if( isDead() ) {
			spr.y-=rnd(0,1);
			spr.scaleY = 1 + Math.cos(game.ftime*0.1)*0.07;
		}

		if( itemIcon!=null ) {
			itemIcon.x = 10;
			itemIcon.y = -1;
			if( MLib.fabs(dx)>=0.01 || MLib.fabs(dy)>=0.01 ) {
				itemIcon.x += Math.sin(game.ftime*0.22)*1;
				itemIcon.y += Math.cos(game.ftime*0.61)*2;
			}
		}

		if( emoteIcon!=null ) {
			emoteIcon.y-=7;
		}

		spr.alpha += ((cd.has("dashing") ? 0.5 : 1)-spr.alpha)*0.3;

		shadow.y+=1;
	}

	public function hit(from:Entity, dmg:Int) {
		gainFollowers(100);
		if( life<=0 )
			return;

		cd.setS("recentHit", 0.3);
		life-=dmg;
		if( life<=0 )
			life = 0;
		ui.Life.ME.blink();
		fx.flashBangS(0xFF0000,0.2,0.3);
		blink();
		jump(0.5);

		var a = from.angTo(this);
		var s = 0.5;
		dx+=Math.cos(a)*s;
		dy+=Math.sin(a)*s;

		if( life<=0 ) {
			dropItem();
			weight = 999;
			cd.setS("lock", 999999);
			zPrio = -20;
			radius = Const.GRID*0.4;
			sayWords("AAAH HEEEEEELP ME!!",0xFF0000);
			game.delayer.addS(function() {
				new ui.TutorialTip(null, "Press R to restart");
			},1.2);
		}
		ui.Life.ME.set(life/maxLife);
	}


	public function isDead() return life<=0;



	override public function update() {
		super.update();

		var spd = 0.03 * (cd.has("dashing") ? 2 : 1);
		if( cd.has("dashing") )
			spr.anim.setStateAnimSpeed("heroWalk",0.6);
		else
			spr.anim.setStateAnimSpeed("heroWalk",0.25);

		if( game.hasCinematic() )
			focus.visible = false;

		if( !game.hasCinematic() && !cd.has("locked") && onGround && !isDead() ) {
			// Movement
			if( Key.isDown(Key.RIGHT) ) {
				Tutorial.ME.complete("controls");
				dir = 1;
				dx += dir*spd;
				cd.setS("walking",0.1);
			}
			else if( Key.isDown(Key.LEFT) ) {
				Tutorial.ME.complete("controls");
				dir = -1;
				dx += dir*spd;
				cd.setS("walking",0.1);
			}

			if( Key.isDown(Key.UP) ) {
				Tutorial.ME.complete("controls");
				dy -= spd;
				cd.setS("walking",0.1);
			}
			else if( Key.isDown(Key.DOWN) ) {
				Tutorial.ME.complete("controls");
				dy += spd;
				cd.setS("walking",0.1);
			}

			// Use
			var dh = new DecisionHelper(en.Interactive.ALL);
			dh.remove( function(e) return !e.canBeActivated(this) || !sightCheck(e) || distCase(e)>2.1 );
			dh.score( function(e) return isLookingAt(e) ? 2 : 0 );
			dh.score( function(e) return distCase(e)<=1.5 ? 5 : 0 );
			dh.score( function(e) return -distCase(e) );
			var useTarget = dh.getBest();
			focus.visible = useTarget!=null;
			if( useTarget!=null )
				focus.setPos(useTarget.footX, useTarget.footY-10 - MLib.fabs( Math.sin(game.ftime*0.2)*6) );

			if( Main.ME.keyPressed(Key.SPACE) ) {
				if( useTarget!=null && ( !useTarget.is(en.inter.ItemDrop) || item==null ) ) {
					useTarget.activate(this);
				}
				else
					dropItem();
			}

			if( side!=null ) {
				// Call sidekick
				if( Main.ME.keyPressed(Key.C) && useTarget!=null )
					side.callOn(useTarget);

				// Cancel sidekick
				if( Main.ME.keyPressed(Key.ESCAPE) )
					side.reset();
			}

			// Roll
			//if( Key.isDown(Key.CTRL) && !cd.has("rollLock") ) {
				//cd.setS("rollLock",0.5);
				//cd.setS("locked",0.4);
				//cd.setS("rolling",0.4);
			//}

			// Run
			if( ( Key.isDown(Key.SHIFT) || Key.isDown(Key.CTRL) ) && !cd.has("dashLock") ) {
				cd.setS("dashing", 0.4);
				cd.setS("dashLock", 1);
				dx*=1.5;
				dy*=1.5;
			}

			rollAng =
				Key.isDown(Key.UP) && Key.isDown(Key.RIGHT) ? -MLib.PIHALF*0.5 :
				Key.isDown(Key.DOWN) && Key.isDown(Key.RIGHT) ? MLib.PIHALF*0.5 :
				Key.isDown(Key.UP) && Key.isDown(Key.LEFT) ? -MLib.PIHALF*1.5 :
				Key.isDown(Key.DOWN) && Key.isDown(Key.LEFT) ? MLib.PIHALF*1.5 :
				Key.isDown(Key.UP) ? -MLib.PIHALF :
				Key.isDown(Key.RIGHT) ? 0 :
				Key.isDown(Key.DOWN) ? MLib.PIHALF :
				Key.isDown(Key.LEFT) ? MLib.PI :
				rollAng;
		}

		#if debug
		// Test
		if( Main.ME.keyPressed(Key.NUMPAD_ENTER) ) {
			//Tutorial.ME.tryToStart("test", "hllow world");
			//pop("hello");
			//hit(this, 1);
			//new en.inter.ItemDrop(Shit, cx+3, cy);
			fx.dirt(footX, footY, 30, 0xA2BDCA, 0x85562C);
		}
		#end

		if( !isDead() ) {
			// Roll effect
			if( cd.has("rolling") ) {
				dx += Math.cos(rollAng)*0.098 * (0.+1*cd.getRatio("rolling"));
				dy += Math.sin(rollAng)*0.098 * (0.+1*cd.getRatio("rolling"));
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

		if( Console.ME.has("fps") )
			setLabel( ""+pretty(hxd.Timer.fps(),1)+" "+pretty(dt,2) );

		if( isDead() && !cd.hasSetS("autoGain",rnd(0.6,1)) )
			gainFollowers(en.Cat.ALL.length*100, true);

		if( followers>0 && !isDead() && !cd.hasSetS("autoGain",rnd(1,2)) )
			gainFollowers(en.Cat.ALL.length<=2 ? irnd(0,1) : en.Cat.ALL.length*2, false);

	}
}