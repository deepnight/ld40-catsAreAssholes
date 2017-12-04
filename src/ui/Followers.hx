package ui;

import mt.heaps.slib.*;
import mt.MLib;

class Followers extends mt.Process {
	public static var ME : Followers;
	var flow : h2d.Flow;
	var field : h2d.Text;
	var cAdd : h3d.Vector;
	var curVal : Int;
	var targetVal : Int;
	var majorUntil = -1;


	public function new() {
		super(Game.ME);
		ME = this;
		curVal = targetVal = 0;
		createRootInLayers(Game.ME.root, Const.DP_UI);

		flow = new h2d.Flow(root);
		flow.backgroundTile = Assets.gameElements.getTile("hudBox");
		flow.borderWidth = flow.borderHeight = 8;
		field = new h2d.Text(Assets.font,flow);
		field.textColor = 0xAEC6D2;
		cAdd = new h3d.Vector();
		field.colorAdd = cAdd;
		set(0,false);
	}

	public function set(v:Int, major:Bool) {
		targetVal = v;
		if( major )
			majorUntil = v;
		cd.setS("shake", major?1:0.2);
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	override public function postUpdate() {
		super.postUpdate();
		root.x = Game.ME.vp.wid*0.25 - flow.outerWidth*0.5;
		root.y = 8;
	}

	public function blink() {
		cAdd.r = rnd(0.6,0.7);
		cAdd.g = rnd(0.6,0.7);
		cAdd.b = rnd(0.6,0.7);
	}

	override public function update() {
		super.update();
		if( cd.has("shake") )
			flow.y = Math.cos(ftime*0.7)*2 * cd.getRatio("shake");
		cAdd.r*=0.8;
		cAdd.g*=0.8;
		cAdd.b*=0.8;

		if( curVal!=targetVal || curVal==0 ) {
			curVal += MLib.ceil((targetVal-curVal)*0.04);

			if( curVal<majorUntil && curVal!=0 && !cd.hasSetS("blinkRoll",0.1) ) {
				cd.setS("shake,",1);
				blink();
			}

			if( MLib.fabs(curVal-targetVal)<=2 )
				curVal = targetVal;
			field.text = curVal<=1 ? (curVal+" follower") : (curVal+" followers");
		}
	}
}
