package ui;

import mt.heaps.slib.*;
import mt.MLib;

class Stamina extends mt.Process {
	static var NORMAL_BEAT = 1;
	public static var ME : Stamina;

	var front : HSprite;
	var back : HSprite;
	var stamina : Float;
	var bar : h2d.Graphics;

	public function new() {
		super(Game.ME);
		ME = this;
		createRootInLayers(Game.ME.root, Const.DP_UI);

		// Bar
		var w = 32;
		var h = 6;
		var s = new h2d.Sprite(root);
		s.y = Std.int(-h*0.5);
		var outline = new h2d.Graphics(s);
		outline.beginFill(0x2D2961,1);
		outline.drawRect(0,0,w+2,h+2);
		var bg = new h2d.Graphics(s);
		bg.beginFill(0x1B1D30,1);
		bg.drawRect(1,1,w,h);
		bar = new h2d.Graphics(s);
		bar.beginFill(0xB12C51,1);
		bar.drawRect(1,1,w,h);

		// Heart
		back = Assets.gameElements.h_get("heartBack",0, 0.4, 0.5, root);
		front = Assets.gameElements.h_get("heartFront",0, 0.6, 0.45, root);
	}

	public function set(v:Float) {
		stamina = v;
	}

	function getSpeed() {
		return 1 + (1-stamina)*4;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	function getBaseScale() return 1 + (1-stamina)*0.35;

	function beat(s:HSprite, power:Float) {
		s.scaleX = getBaseScale() + 0.2+power*0.6 + getSpeed()*0.1;
		s.scaleY = getBaseScale() + 0.2-power*0.4 + getSpeed()*0.1;
		s.rotation = rnd(0.08,0.12,true) * power;
	}

	override public function postUpdate() {
		super.postUpdate();
		root.x = Std.int(Game.ME.vp.wid*0.5);
		root.y = 16;

		bar.scaleX += ( MLib.fclamp(stamina,0,1) - bar.scaleX ) * 0.2;

		front.setPos(-10,2);
		front.scaleX+=(getBaseScale()-front.scaleX)*0.3;
		front.scaleY+=(getBaseScale()-front.scaleY)*0.3;
		front.rotation+=(0-front.rotation)*0.3;

		back.setPos(-10,2);
		back.scaleX+=(getBaseScale()-back.scaleX)*0.3;
		back.scaleY+=(getBaseScale()-back.scaleY)*0.3;
		back.rotation+=(0-back.rotation)*0.3;
	}

	override public function update() {
		super.update();
		if( !cd.has("beat") ) {
			beat(front, 1-stamina);
			delayer.addS(beat.bind(back,1-stamina), 0.06);
			cd.setS("beat",NORMAL_BEAT/getSpeed(), true);
			cd.setS("secBeat", 0.1/getSpeed(), function() {
				beat(front, (1-stamina)*0.7);
				delayer.addS(beat.bind(back, (1-stamina)*0.7), 0.03);
			}, true);
		}
	}
}
