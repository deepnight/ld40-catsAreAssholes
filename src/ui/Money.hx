package ui;

import mt.heaps.slib.*;
import mt.MLib;

class Money extends mt.Process {
	public static var ME : Money;
	var flow : h2d.Flow;
	var money : h2d.Text;
	var cAdd : h3d.Vector;

	public function new() {
		super(Game.ME);
		ME = this;
		createRootInLayers(Game.ME.root, Const.DP_UI);

		flow = new h2d.Flow(root);
		money = new h2d.Text(Assets.font,flow);
		cAdd = new h3d.Vector();
		money.colorAdd = cAdd;
		set(0);
	}

	public function set(v:Int) {
		money.text = "$"+v;
		money.textColor = 0xFFB300;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	override public function postUpdate() {
		super.postUpdate();
		flow.x = Game.ME.vp.wid*0.25 - flow.outerWidth*0.5;
	}

	public function blink() {
		cd.setS("shake", 1);
		cAdd.r = 0.9;
		cAdd.g = 0.9;
		cAdd.b = 0.9;
	}

	override public function update() {
		super.update();
		if( cd.has("shake") ) {
			flow.y = Math.cos(ftime*0.7)*2 * cd.getRatio("shake");
		}
		cAdd.r*=0.8;
		cAdd.g*=0.8;
		cAdd.b*=0.8;
	}
}
