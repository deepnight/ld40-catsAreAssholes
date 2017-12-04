package en.h;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

enum Action {
	GoCoord(cx:Int,cy:Int, cb:Void->Void);
	GoInter(e:en.Interactive);
	ContinueIf(cb:Void->Bool);
	AbandonIf(cb:Void->Bool);
	RepeatPrevIf(cb:Void->Bool,tries:Int);
}

class Sidekick extends en.Hero {
	var actions : Array<Action>;
	var actionIdx = 0;
	var maxTries = 3;
	var tries = 0;
	var path : mt.deepnight.PathFinder.Path;

	var maxQueue = 2;
	var queue : Array<Entity>;
	var pointers : Array<HSprite>;

	var restX : Int;
	var restY : Int;
	var quotes : Array<String>;

	public function new(x,y) {
		super(x,y);

		game.side = this;
		path = [];
		actions = [];
		quotes = ["Hey, I followed your new cat-oriented Twitch stream by the way."];
		queue = [];
		weight = 0.2;

		restX = 11;
		restY = 11;

		spr.anim.registerStateAnim("sideWalk",3, 0.2, function() return MLib.fabs(dx)>0 || MLib.fabs(dy)>0 );
		spr.anim.registerStateAnim("sideIdleTv",1, 0.6, function() return cx==restX && cy==restY && dir==-1);
		spr.anim.registerStateAnim("sideIdle",0);

		spr.lib.defineAnim("sideWalk", "0(2),1,2(2),1");
		spr.lib.defineAnim("sideIdleTv", "0,1,2(2),1(3),2,1,0(2),2,1,0,2(2),1,0,1,0");

		enableShadow(1.5);
		pointers = [];
		for(i in 0...3) {
			var e = Assets.gameElements.h_get("pointer",i, 0.5,1);
			game.scroller.add(e, Const.DP_UI);
			pointers.push(e);
			e.visible = false;
		}

		game.cm.create( {
			500;
			lookAt(hero);
			hero.lookAt(this);
			sayWords("Hey nanny.");
			1000;
			hero.sayWords("Ho, hi Mark.");
			1300;
			clearWords();
			Tutorial.ME.tryToStart("side", "Press C near something useful (like a bowl, or a dirty litter box) to ask Mark to take care of it.");
			onDone();
		});
	}

	override public function dispose() {
		super.dispose();
		for(e in pointers)
			e.remove();
		pointers = null;
	}

	function pickOne<T>(all:Array<T>) : T {
		return all[Std.random(all.length)];
	}

	function pickTrashCan() : en.inter.TrashCan {
		var dh = new DecisionHelper(en.inter.TrashCan.ALL);
		dh.score( function(e) return -distCase(e) );
		return dh.getBest();
	}

	function pickItem(k:Data.ItemKind) : en.inter.ItemDrop {
		var dh = new DecisionHelper(en.inter.ItemDrop.ALL);
		dh.remove( function(e) return e.k!=k );
		dh.score( function(e) return -distCase(e) );
		dh.score( function(e) return rnd(0,0.9) );
		return dh.getBest();
	}

	function pickFridge(mustHaveFish:Bool, ?prio:Entity) : en.inter.Fridge {
		var dh = new DecisionHelper(en.inter.Fridge.ALL);
		dh.remove( function(e) return mustHaveFish && e.isEmpty() );
		dh.score( function(e) return !e.cd.has("lock") ? 1 : 0 );
		dh.score( function(e) return e==prio ? 1 : 0 );
		dh.score( function(e) return rnd(0,0.9) );
		return dh.getBest();
	}

	function pickFoodTray() : en.inter.FoodTray {
		var dh = new DecisionHelper(en.inter.FoodTray.ALL);
		dh.remove( function(e) return e.isFull() );
		dh.score( function(e) return -e.stock );
		return dh.getBest();
	}

	public function callOn(e:Entity) {
		for(qe in queue)
			if( qe==e )
				return;

		if( actions.length>0 ) {
			emote("eQuestion",0.5);
			if( queue.length<maxQueue )
				queue.push(e);
			return;
		}
		clearActions();

		if( e.is(en.inter.Litter) ) {
			var e = e.as(en.inter.Litter);
			var t = pickTrashCan();
			emote("eShit");
			actions = [
				GoInter(e),
				AbandonIf(function() return item==null),
				GoInter(t),
			];
		}

		if( e.is(en.inter.Shop) ) {
			emote("eQuestion");
			//var e = e.as(en.inter.Shop);
			//emote("eCall");
			//actions = [
				//GoInter(e),
			//];
		}

		if( e.is(en.inter.Fridge) ) {
			emote("eQuestion");
			//var f = e.as(en.inter.Fridge);
			//var t = pickFoodTray();
			//if( t!=null ) {
				//emote("eFood");
				//actions = [
					//GoInter(f),
					//RepeatPrevIf(function() return item==null, 4),
					//GoInter(t),
				//];
			//}
		}

		if( e.is(en.inter.FoodTray) ) {
			if( e.as(en.inter.FoodTray).isFull() ) {
				emote("eQuestion");
			}
			else {
				var from : en.Interactive = pickFridge(true,e);
				if( from==null )
					from = pickItem(FishCan);
				if( from==null )
					emote("eError");
				else {
					var t = e.as(en.inter.FoodTray);
					emote("eFood");
					actions = [
						GoInter(from),
						RepeatPrevIf(function() return item==null, 4),
						GoInter(t),
					];
				}
			}
		}

		if( e.is(en.inter.ItemDrop) ) {
			var e = e.as(en.inter.ItemDrop);
			switch( e.k ) {
				case Data.ItemKind.FishCan :
					var t = pickFoodTray();
					emote("eFood");
					if( t!=null )
						actions = [ GoInter(e), GoInter(t) ];
					else
						emote("eQuestion");

				case Data.ItemKind.FoodBox :
					var t = pickFridge(false);
					if( t!=null ) {
						emote("eFood");
						actions = [ GoInter(e), GoInter(t) ];
					}
					else
						emote("eQuestion");

				case Data.ItemKind.FridgeUp :
					var t = pickFridge(false);
					if( t!=null ) {
						emote("eUp");
						actions = [ GoInter(e), GoInter(t) ];
					}
					else
						emote("eQuestion");

				case Data.ItemKind.Trash, Data.ItemKind.Shit :
					emote("eShit");
					var t = pickTrashCan();
					actions = [ GoInter(e), GoInter(t) ];

				case CatBox :
					actions = [ GoInter(e) ];

				default :
					emote("eQuestion");
			}
		}

		if( actions.length>0 )
			Tutorial.ME.complete("side");
	}

	function goto(x,y) {
		if( level.hasColl(x,y) )
			y++;
		path = level.pf.getPath( { x:cx, y:cy, } , { x:x, y:y } );
		path = level.pf.smooth(path);
	}

	function clearActions() {
		actions = [];
		tries = 0;
		actionIdx = 0;
		path = [];
	}

	function abandon() {
		emote("eError", 1.5);
		clearActions();
		onDone();
	}

	public function reset() {
		queue = [];
		abandon();
	}

	function nextAction() {
		var a = actions[actionIdx];
		actionIdx++;
		tries = 0;
		path = [];
		switch( a ) {
			case GoCoord(_), GoInter(_) : cd.setS("lock",0.5);
			case RepeatPrevIf(_) :
			case ContinueIf(_), AbandonIf(_) :
		}

		if( actionIdx>=actions.length ) {
			clearActions();
			onDone();
		}
	}

	function onDone() {
		dropItem();
		cd.setS("lock", 0.5);
		if( queue.length>0 )
			callOn( queue.shift() );
		else
			goto(restX,restY);
	}


	function setPointer(id:Int, x:Float, y:Float) {
		var e = pointers[id];
		e.visible = true;
		e.x = x;
		e.y = y - 8 - MLib.fabs( Math.sin(game.ftime*0.1)*9 );
	}


	override public function postUpdate() {
		super.postUpdate();

		for(e in pointers)
			e.visible = false;

		if( actionIdx<actions.length ) {
			var a = actions[actionIdx];
			switch( a ) {
				case GoInter(e) :
					if( e.is(en.inter.Fridge) )
						a = actions[actions.length-1];
				default :
			}
			switch( a ) {
				case GoInter(e) : setPointer(0, e.footX, e.footY);
				case GoCoord(x,y,_) : setPointer(0, (x+0.5)*Const.GRID,(y+1)*Const.GRID);
				default :
			}
		}

		for( i in 0...queue.length )
			setPointer(i+1, queue[i].footX, queue[i].footY);


		if( itemIcon!=null ) {
			itemIcon.x = 10;
			itemIcon.y = -3;
			if( MLib.fabs(dx)>=0.01 || MLib.fabs(dy)>=0.01 ) {
				itemIcon.x += Math.sin(game.ftime*0.22)*1;
				itemIcon.y += Math.cos(game.ftime*0.61)*1;
			}
		}
	}

	override function onTouch(e:Entity) {
		super.onTouch(e);
		if( e.is(en.h.Grandma) && path.length==0 ) {
			cd.setS("goRest", 1);
			lookAt(e);
		}
	}

	override public function update() {
		super.update();

		#if debug
		if( Console.ME.has("path") ) {
			for(pt in path)
				fx.markerCase(pt.x,pt.y,0xFF8000, true);
		}
		#end

		if( actionIdx<actions.length && !cd.has("lock") && !game.hasCinematic() ) {
			var a = actions[actionIdx];
			if( Console.ME.has("side") )
				setLabel(Std.string(a)+" tries="+tries+" q="+queue.length);

			switch( a ) {
				case GoCoord(x,y,cb) :
					if( cx==x && cy==y ) {
						if( cb!=null )
							cb();
						nextAction();
					}
					else if( path.length==0 )
						goto(x,y);

				case GoInter(e) :
					if( e.destroyed )
						abandon();
					else {
						if( distCase(e)>1 && path.length==0 )
							goto(e.cx,e.cy);
						if( distCase(e)<=1.2 ) {
							if( !e.canBeActivated(this) ) {
								if( tries++<maxTries )
									cd.setS("lock",1);
								else
									abandon();
							}
							else {
								e.activate(this);
								nextAction();
							}
						}
					}

				case RepeatPrevIf(cb,tries) :
					if( cb() ) {
						if( tries<=0 )
							abandon();
						else {
							actions[actionIdx] = RepeatPrevIf(cb,tries-1);
							actionIdx--;
							cd.setS("lock",1);
						}
					}
					else
						nextAction();

				case ContinueIf(cb) :
					if( cb() )
						nextAction();
					else
						abandon();

				case AbandonIf(cb) :
					if( cb() )
						abandon();
					else
						nextAction();
			}
		}

		#if debug
		if( Console.ME.has("side") && actions.length==0 )
			setLabel("--");
		#end


		// Follow path
		if( !game.hasCinematic() && path.length>0 && !cd.has("lock") ) {
			var spd = 0.02;
			var next = path[0];
			if( cx==next.x && cy==next.y ) {
				path.shift();
				next = path[0];
			}
			if( next!=null && ( cx!=next.x || cy!=next.y ) ) {
				var a = Math.atan2(next.y+0.5-(cy+yr), (next.x+0.5)-(cx+xr));
				dx += Math.cos(a)*spd;
				dy += Math.sin(a)*spd;
				dir = Math.cos(a)>=0.1 ? 1 : Math.cos(a)<=-0.1 ? -1 : dir;
				if( !sightCheckCase(next.x,next.y) )
					path = [];
			}
		}

		if( cx==restX && cy==restY ) {
			dir = -1;
			if( !cd.hasSetS("randTalk",rnd(15,30)) ) {
				hero.gainFollowers(1);
				if( quotes.length==0 ) {
					quotes = [
						"You know Pewdiedie?",
						"This new video kicks ass.",
						"Seriously?",
						"You really should try out 9gag nanny.",
						"This show really sucks.",
						"I'd love a cookie.",
						"Do you have cookies?",
						"So what's up on Facebook?",
						"ROFL.",
						"LOL...",
						"Ah ah ah.",
					];
					Lib.shuffleArray(quotes, Std.random);
				}
				sayWords( quotes.shift() );
			}
		}
		else if( item==null && queue.length==0 && actions.length==0 && path.length==0 && !cd.has("goRest") )
			goto(restX, restY);
	}
}