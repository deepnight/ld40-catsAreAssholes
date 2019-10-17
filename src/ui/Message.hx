package ui;

class Message extends dn.Process {
	var flow : h2d.Flow;
	var cAdd : h3d.Vector;

	public function new(txt:String) {
		super(Game.ME);

		cAdd = new h3d.Vector();
		createRootInLayers(Game.ME.root, Const.DP_TOP);

		flow = new h2d.Flow(root);
		flow.backgroundTile = Assets.gameElements.getTile("hudBox");
		flow.borderWidth = flow.borderHeight = 8;
		flow.layout = Vertical;
		flow.verticalSpacing = 4;
		flow.horizontalAlign = Middle;
		flow.paddingBottom = 2;

		var tf = new h2d.Text(Assets.font,flow);
		tf.text = txt;
		tf.textColor = 0xFFC716;
		tf.maxWidth = 220;

		tw.createS(flow.y, 100>0, TElasticEnd, 0.3);
		for(i in 0...8)
			delayer.addS(blink, 0.5+i*0.33);

		cd.setS("alive", 1.5);
	}

	function blink() {
		cAdd.r = 0.9;
		cAdd.g = 0.9;
		cAdd.b = 0.9;
	}

	public function close() {
		tw.createS(flow.x, 20, 0.2);
		tw.createS(flow.y, 100, 0.2).end( destroy );
	}

	override public function postUpdate() {
		super.postUpdate();
		root.x = Std.int( Game.ME.vp.wid*0.5 - flow.outerWidth*0.5 );
		root.y = Std.int( Game.ME.vp.hei - flow.outerHeight - 40 );
	}

	override public function update() {
		super.update();
		cAdd.r*=0.8;
		cAdd.g*=0.8;
		cAdd.b*=0.8;
		if( !cd.has("alive") && !cd.hasSetS("closeOnce",99999) )
			close();
	}
}
