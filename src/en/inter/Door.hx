package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

enum DoorEvent {
	Deliver(k:Data.ItemKind);
}

class Door extends en.Interactive {
	public static var ALL : Array<Door> = [];

	var events : Array<{ k:DoorEvent, t:Float }>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		events = [];
		spr.set("empty");
		radius = Const.GRID*0.3;
		weight = -1;
		footOffsetY = -4;
		zPrio = -99;
	}

	public function hasAnyEvent() {
		return events.length>0;
	}

	public function hasEvent(k:DoorEvent) {
		for(e in events)
			if( e.k==k )
				return true;
		return false;
	}

	public function addEvent(k:DoorEvent, sec:Float) {
		events.push( { k:k, t:game.ftime+sec*Const.FPS } );
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function canBeActivated(by:Hero) {
		return false;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
	}

	function doEvent(k:DoorEvent) {
		switch( k ) {
			case Deliver(ik) :
				var e = new en.inter.ItemDrop(ik, cx,cy);
				e.dx = rnd(0,0.2,true);
				e.dy = 0.3;
				jump(1);
		}
	}
	override public function update() {
		super.update();

		if( events.length>0 ) {
			var e = events[0];
			setLabel(pretty((e.t-game.ftime)/Const.FPS)+"s");
			if( game.ftime>=e.t ) {
				events.shift();
				doEvent(e.k);
			}
		}
		else
			setLabel();
	}
}