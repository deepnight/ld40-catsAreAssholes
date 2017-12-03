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

	var queued : Null<Entity>;
	var pointers : Array<HSprite>;

	public function new(x,y) {
		super(x,y);

		path = [];
		actions = [];
		weight = -1;

		spr.anim.registerStateAnim("sideWalk",3, 0.2, function() return MLib.fabs(dx)>0 || MLib.fabs(dy)>0 );
		spr.anim.registerStateAnim("sideIdle",0);

		pointers = [];
		for(i in 0...2) {
			var e = Assets.gameElements.h_get("pointer",i, 0.5,1);
			game.scroller.add(e, Const.DP_UI);
			pointers.push(e);
			e.visible = false;
		}
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

	function pickFridge(?prio:Entity) : en.inter.Fridge {
		var dh = new DecisionHelper(en.inter.Fridge.ALL);
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
		if( actions.length>0 && queued!=e ) {
			queued = e;
			return;
		}
		clearActions();
		trace(e);

		if( e.is(en.inter.Litter) ) {
			var e = e.as(en.inter.Litter);
			var t = pickTrashCan();
			say("eShit");
			actions = [
				GoInter(e),
				AbandonIf(function() return item==null),
				GoInter(t),
			];
		}

		if( e.is(en.inter.Fridge) ) {
			var f = e.as(en.inter.Fridge);
			var t = pickFoodTray();
			if( t!=null ) {
				say("eFood");
				actions = [
					GoInter(f),
					RepeatPrevIf(function() return item==null, 4),
					GoInter(t),
				];
			}
		}

		if( e.is(en.inter.FoodTray) ) {
			var f = pickFridge(e);
			var t = e.as(en.inter.FoodTray);
			say("eFood");
			actions = [
				GoInter(f),
				RepeatPrevIf(function() return item==null, 4),
				GoInter(t),
			];
		}

		if( e.is(en.inter.ItemDrop) ) {
			var e = e.as(en.inter.ItemDrop);
			dropItem();
			actions = [
				GoInter(e),
			];
			switch( e.k ) {
				case Data.ItemKind.Fish :
					var t = pickFoodTray();
					say("eFood");
					if( t!=null ) actions.push( GoInter(t) );

				case Data.ItemKind.FoodBox :
					var t = pickFridge();
					say("eFood");
					if( t!=null ) actions.push( GoInter(t) );

				case Data.ItemKind.Trash, Data.ItemKind.Shit :
					say("eShit");
					var t = pickTrashCan();
					actions.push( GoInter(t) );

				default :
			}
		}
	}

	function goto(x,y) {
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
		say("eError", 1.5);
		clearActions();
		onDone();
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
		if( queued!=null ) {
			var e = queued;
			queued = null;
			callOn(e);
		}
		else
			goto(10,10);
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

		if( queued!=null )
			setPointer(1, queued.footX, queued.footY);
	}

	override public function update() {
		super.update();

		if( actionIdx<actions.length && !cd.has("lock") ) {
			var a = actions[actionIdx];
			if( Console.ME.has("side") )
				setLabel(Std.string(a)+" tries="+tries);

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
		if( path.length>0 && !cd.has("lock") ) {
			var spd = 0.02;
			var next = path[0];
			if( cx==next.x && cy==next.y ) {
				path.shift();
				next = path[0];
			}
			if( next!=null && ( cx!=next.x || cy!=next.y ) ) {
				var a = Math.atan2(next.y-cy, next.x-cx);
				dx += Math.cos(a)*spd;
				dy += Math.sin(a)*spd;
				dir = Math.cos(a)>=0.1 ? 1 : Math.cos(a)<=-0.1 ? -1 : dir;
			}
		}

	}
}