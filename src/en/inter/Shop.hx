package en.inter;

class Shop extends en.Interactive {
	public static var ME : Shop;
	var door(get,never) : en.inter.Door; inline function get_door() return en.inter.Door.ALL[0];

	var boughts : Array<Data.ItemKind>;

	public function new(x,y) {
		super(x,y);
		ME = this;
		yr = 1;
		boughts = [];
		spr.set("empty");
		radius = Const.GRID*0.3;
		weight = -1;
		zPrio = -99;
	}

	public function register(k:Data.ItemKind) {
		boughts.push(k);
		if( k==CatBox )
			door.onNextCat();
	}

	public function countPreviousBoughts(k:Data.ItemKind) {
		var n = 0;
		for(i in boughts)
			if( i==k )
				n++;
		return n;
	}

	override public function dispose() {
		super.dispose();
		if( ME==this )
			ME = null;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( Tutorial.ME.hasDone("side") )
			Tutorial.ME.complete("shop2");
		Tutorial.ME.complete("shop");
		Tutorial.ME.complete("food");
		new ui.ShopWindow();
	}

	override public function update() {
		super.update();
	}
}