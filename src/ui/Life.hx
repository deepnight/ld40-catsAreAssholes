package ui;

import mt.heaps.slib.*;
import mt.MLib;

class Life extends mt.Process {
	static var NORMAL_BEAT = 0.85;
	public static var ME : Life;

	var barWid = 60;
	var barHei = 5;
	var front : HSprite;
	var back : HSprite;
	var value = 1.0;
	var bg : h2d.ScaleGrid;
	var bar : h2d.Graphics;
	var cAdd : h3d.Vector;

	public function new() {
		super(Game.ME);
		ME = this;
		createRoot(Game.ME.hudWrapper);

		cAdd = new h3d.Vector();

		bg = new h2d.ScaleGrid(Assets.gameElements.getTile("hudBox"), 8,8, root);
		//bg.x = -24;
		//bg.y = -12;
		bg.width = barWid+32;
		bg.height = 26;

		// Bar
		var s = new h2d.Object(root);
		s.x = 24;
		s.y = 12-barHei*0.5;
		var outline = new h2d.Graphics(s);
		outline.beginFill(0xc86e36,1);
		outline.drawRect(0,0,barWid+2,barHei+2);
		var bg = new h2d.Graphics(s);
		bg.beginFill(0x371E0F,1);
		bg.drawRect(1,1,barWid,barHei);
		bar = new h2d.Graphics(s);
		bar.beginFill(0xE62639,1);
		bar.drawRect(1,1,barWid,barHei);
		bar.colorAdd = cAdd;

		// Heart
		back = Assets.gameElements.h_get("heartBack",0, 0.4, 0.5, root);
		front = Assets.gameElements.h_get("heartFront",0, 0.6, 0.45, root);
		back.colorAdd = cAdd;
		front.colorAdd = cAdd;
	}

	public function set(v:Float) {
		value = v;
	}

	function getSpeed() {
		return value<=0 ? 0 : 1 + (1-value)*4;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	function getBaseScale() return 0.75 + (1-value)*0.15;

	function beat(s:HSprite, power:Float) {
		s.scaleX = getBaseScale() + 0.2+power*0.4 + getSpeed()*0.1;
		s.scaleY = getBaseScale() + 0.2-power*0.3 + getSpeed()*0.1;
		s.rotation = rnd(0.08,0.12,true) * power;
	}

	override public function postUpdate() {
		super.postUpdate();
		if( cd.has("shake") )
			root.y += Math.cos(ftime*0.7)*2 * cd.getRatio("shake");

		bar.scaleX += ( MLib.fclamp(value,0,1) - bar.scaleX ) * 0.4;

		var recalSpd = 0.1 + 0.2*(1-value);
		front.setPos(17,14);
		front.scaleX+=(getBaseScale()-front.scaleX)*recalSpd;
		front.scaleY+=(getBaseScale()-front.scaleY)*recalSpd;
		front.rotation+=(0-front.rotation)*recalSpd;

		back.setPos(16,14);
		back.scaleX+=(getBaseScale()-back.scaleX)*recalSpd;
		back.scaleY+=(getBaseScale()-back.scaleY)*recalSpd;
		back.rotation+=(0-back.rotation)*recalSpd;
	}

	public function blink() {
		cd.setS("shake", 1);
		cAdd.r = 0.9;
		cAdd.g = 0.9;
		cAdd.b = 0.9;
	}

	override public function update() {
		super.update();
		if( value>=0 && !cd.has("beat") ) {
			beat(front, 1-value);
			delayer.addS(beat.bind(back,1-value), 0.06);
			cd.setS("beat",NORMAL_BEAT/getSpeed(), true);
			cd.setS("secBeat", 0.1/getSpeed(), function() {
				beat(front, (1-value)*0.7);
				delayer.addS(beat.bind(back, (1-value)*0.7), 0.03);
			}, true);
		}
		cAdd.r*=0.8;
		cAdd.g*=0.8;
		cAdd.b*=0.8;
	}
}
