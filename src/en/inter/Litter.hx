package en.inter;

class Litter extends en.Interactive {
	public static var ALL : Array<Litter> = [];
	var max = 5;
	var stock = 0;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		zPrio = -999;
		weight = 1;
	}

	override function hasCircCollWith(e:Entity) {
		return super.hasCircCollWith(e) && e.is(Litter);
	}

	public function isEmpty() return stock==0;
	public function isFull() return stock>=max;

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function onActivate(by:Hero) {
		super.onActivate(by);
		if( stock>0 ) {
			by.pick(-1, Trash);
			stock = 0;
		}
	}

	override public function canBeActivated(by:Hero) {
		return super.canBeActivated(by) && stock>0;
	}

	public function addShit(n) {
		stock = M.imin(stock+n, max);
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.y+=10;
		spr.set("litter", stock>=max ? 3 : stock>=max*0.5 ? 2 : stock>0 ? 1 : 0);

		if( isFull() && !cd.hasSetS("warning",1) )
			blink();
	}

	override public function update() {
		super.update();
		#if debug
		stock = 0;
		#end
	}
}