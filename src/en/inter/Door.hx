package en.inter;

import mt.MLib;
import mt.heaps.slib.*;
import hxd.Key;

enum DoorEvent {
	Deliver(k:Data.ItemKind);
}

class Door extends en.Interactive {
	public static var ALL : Array<Door> = [];
	static var AUTO_CAT = [ 20, 45, 60 ];
	var events : Array<{ k:DoorEvent, frames:Float }>;

	var cats = 0;
	var autoCatCptF = 0.;

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
		open();
		game.delayer.addS(function() {
			switch( k ) {
				case Deliver(ik) :
					switch( ik ) {
						case Kid :
							new en.h.Sidekick(cx,cy+1);

						default :
							var e = new en.inter.ItemDrop(ik, cx,cy);
							e.skew = 1;
							e.dx = rnd(0,0.2,true);
							e.dy = rnd(0.3,0.5);
							jump(1);
					}
			}
		},0.3);
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
		if( label!=null ) {
			label.textColor = 0xD66143;
			label.y+=14;
		}
	}

	override public function setLabel(?str:String, ?c = 0xFFFFFF) {
		super.setLabel(str, c);
		if( str!=null )
			game.scroller.add(label, Const.DP_BG);
	}

	public function onNextCat() {
		autoCatCptF = 0;
		if( side!=null )
			side.sayWords("A new cat has arrived nanny.");
		cats++;
	}

	override public function update() {
		super.update();

		autoCatCptF+=dt;
		var next = AUTO_CAT[MLib.min(cats,AUTO_CAT.length-1)];
		if( autoCatCptF>=next*Const.FPS ) {
			doEvent(Deliver(CatBox));
			onNextCat();
		}
		var t = MLib.ceil(next-autoCatCptF/Const.FPS);
		if( t<60 )
			setLabel(t+"s");
		else
			setLabel(Std.int(t/60)+"m "+(t-Std.int(t/60)*60)+"s");

		if( events.length>0 ) {
			var e = events[0];
			e.frames -= dt;
			if( e.frames<=0 ) {
				events.shift();
				doEvent(e.k);
			}
		}
	}
}