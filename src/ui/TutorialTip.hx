package ui;

class TutorialTip extends dn.Process {
	public static var ME : TutorialTip;
	var flow : h2d.Flow;
	var cAdd : h3d.Vector;
	public var tutoId : String;

	public function new(tutoId:String, txt:String) {
		super(Game.ME);
		if( ME!=null )
			ME.close();

		cAdd = new h3d.Vector();
		this.tutoId = tutoId;
		ME = this;
		createRootInLayers(Game.ME.root, Const.DP_UI);

		flow = new h2d.Flow(root);
		flow.backgroundTile = Assets.gameElements.getTile("hudBox");
		flow.borderWidth = flow.borderHeight = 8;
		flow.isVertical = true;
		flow.verticalSpacing = 4;
		flow.horizontalAlign = Middle;
		flow.paddingBottom = 2;

		var tf = new h2d.Text(Assets.font,flow);
		tf.text = "Tutorial tip";
		tf.textColor = 0xFFB300;
		tf.colorAdd = cAdd;

		var tf = new h2d.Text(Assets.font,flow);
		tf.text = txt;
		tf.textColor = 0x15FFA8;
		tf.maxWidth = 220;
		//tf.colorAdd = cAdd;

		tw.createS(flow.y, 100>0, TElasticEnd, 0.3);
		for(i in 0...8)
			delayer.addS(blink, 0.5+i*0.33);
	}

	function blink() {
		cAdd.r = 0.9;
		cAdd.g = 0.9;
		cAdd.b = 0.9;
	}

	public function close() {
		if( ME==this )
			ME = null;
		tw.createS(flow.x, 20, 0.2);
		tw.createS(flow.y, 100, 0.2).end( destroy );
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
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
	}
}
