class MoneyMan extends mt.Process {
	public function new() {
		super(Game.ME);
	}

	public function trigger(e:Entity, k:Data.MoneySourceKind) {
		var inf = Data.moneySource.get(k);
		if( cd.has("source"+inf.index) )
			return;

		cd.setS("source"+inf.index, inf.cd);
		var v = inf.maxValue==null ? inf.value : irnd(inf.value, inf.maxValue);
		for( i in 0...inf.value )
			new en.Coin(1, e.cx,e.cy);
	}
}