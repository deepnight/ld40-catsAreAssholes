package en.inter;

class Fridge extends en.Interactive {
	public static var ALL : Array<Fridge> = [];
	var max(get,never) : Int;
	var stock = 0;
	var upgrade = 0;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		spr.set("empty");
		yr = 1;
		radius = Const.GRID*0.3;
		weight = 999;
		zPrio = -99;
		stock = max;
	}

	inline function get_max() return 5 + upgrade*2;

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function isEmpty() return stock==0;

	override public function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && ( by.item==null && stock>0 || by.item==FishCan && stock<max || by.item==FoodBox && stock<max || by.item==FridgeUp ) ;
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( by.item==FoodBox ) {
			for(i in 0...stock) {
				var e = new en.inter.ItemDrop(FishCan,cx,cy);
				e.dx = rnd(0,0.2,true);
				e.dy = rnd(0.2,0.6);
			}
			stock = max;
			by.destroyItem();
		}
		else if( by.item==FridgeUp ) {
			var old = max;
			upgrade++;
			stock+=max-old;
			Assets.SBANK.upgrade0(1);
			by.destroyItem();
		}
		else if( by.item==FishCan ) {
			stock++;
			Assets.SBANK.drop1(1);
			by.destroyItem();
		}
		else {
			by.pick(-1, FishCan);
			Assets.SBANK.fridge0(1);
			stock--;
		}
	}

	override public function postUpdate() {
		super.postUpdate();
		if( label!=null ) {
			label.x+=3;
			label.y -= 32;
		}
	}
	override public function update() {
		super.update();
		setLabel(stock+"/"+max, stock==0 ? 0xFF0000 : stock<=2 ? 0xFE8001 : 0xFFFFFF);
	}
}