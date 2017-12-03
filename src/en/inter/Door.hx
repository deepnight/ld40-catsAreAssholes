package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

enum DoorEvent {
	Deliver(k:Data.ItemKind);
}

class Door extends en.Interactive {
	public static var ALL : Array<Door> = [];

	var events : Array<{ k:DoorEvent, frames:Float }>;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		events = [];
		spr.set("empty");
		radius = Const.GRID*0.3;
		weight = -1;
		footOffsetY = -4;
		zPrio = -99;

		//addEvent( Deliver(CatBox), 2 );
		//addEvent( Deliver(CatBox), 2 );
		//addEvent( Deliver(CatBox), 2 );
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
		events.push( { k:k, frames:sec*Const.FPS } );
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
				e.skew = 1;
				e.dx = rnd(0,0.2,true);
				e.dy = rnd(0.3,0.5);
				jump(1);
		}
	}

	public function open() {
		var s = Assets.gameElements.h_get("doorOpen",0, 0.5,1);
		s.x = footX;
		s.y = footY+16;
		game.scroller.add(s, Const.DP_BG);
		game.tw.createS(s.alpha, 0>1, 0.2)
			.chainMs(1000|0)
			.end( function() {
				s.remove();
			});
	}

	override public function postUpdate() {
		super.postUpdate();
		if( label!=null )
			label.y-=32;
	}

	override public function update() {
		super.update();

		if( events.length>0 ) {
			var e = events[0];
			e.frames -= dt;
			setLabel(MLib.ceil(e.frames/Const.FPS)+"s");
			if( e.frames<=0 ) {
				events.shift();
				game.delayer.addS( doEvent.bind(e.k), 0.3 );
				open();
			}
		}
		else
			setLabel();
	}
}