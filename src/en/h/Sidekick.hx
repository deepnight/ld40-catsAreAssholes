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

	public function new(x,y) {
		super(x,y);

		path = [];
		actions = [];
		weight = -1;

		spr.anim.registerStateAnim("sideWalk",3, 0.2, function() return MLib.fabs(dx)>0 || MLib.fabs(dy)>0 );
		spr.anim.registerStateAnim("sideIdle",0);
	}

	function pickOne<T>(all:Array<T>) : T {
		return all[Std.random(all.length)];
	}

	function pickTrashCan() : en.inter.TrashCan {
		return cast pickOne( Entity.ALL.filter(function(e) return e.is(en.inter.TrashCan)) );
	}

	function pickFridge(?prio:Entity) : en.inter.Fridge {
		var dh = new DecisionHelper(en.inter.Fridge.ALL);
		dh.score( function(e) return !e.cd.has("lock") ? 1 : 0 );
		dh.score( function(e) return e==prio ? 1 : 0 );
		dh.score( function(e) return rnd(0,0.9) );
		return dh.getBest();
	}

	function pickFoodTrail() : en.inter.Food {
		var dh = new DecisionHelper(en.inter.Food.ALL);
		dh.remove( function(e) return e.isFull() );
		dh.score( function(e) return -e.stock );
		return dh.getBest();
	}

	public function callOn(e:Entity) {
		clearActions();
		trace(e);

		if( e.is(en.inter.Litter) ) {
			var e = e.as(en.inter.Litter);
			var t = pickTrashCan();
			actions = [
				GoInter(e),
				AbandonIf(function() return item==null),
				GoInter(t),
			];
		}

		if( e.is(en.inter.Fridge) ) {
			var f = e.as(en.inter.Fridge);
			var t = pickFoodTrail();
			if( t!=null ) {
				actions = [
					GoInter(f),
					RepeatPrevIf(function() return item==null, 4),
					GoInter(t),
				];
			}
		}

		if( e.is(en.inter.Food) ) {
			var f = pickFridge(e);
			var t = e.as(en.inter.Food);
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
					var t = pickFoodTrail();
					if( t!=null ) actions.push( GoInter(t) );

				case Data.ItemKind.Trash, Data.ItemKind.Shit :
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
		goto(hero.cx, hero.cy);
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