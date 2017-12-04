class MoneyMan extends mt.Process {
	public function new() {
		super(Game.ME);
	}

	public function trigger(e:Entity, k:Data.MoneySourceKind) {
		var inf = Data.moneySource.get(k);
		if( cd.has("source"+inf.index) )
			return;

		cd.setS("source"+inf.index, inf.cd);
		var catIdx = e.is(en.Cat) ? e.as(en.Cat).catIdx : -1;
		var cValue = catIdx>=6 ? 3 : catIdx>=3 ? 2 : 1;
		var v = inf.maxValue==null ? inf.value : irnd(inf.value, inf.maxValue);
		for( i in 0...inf.value )
			new en.Coin(cValue, e.cx,e.cy);
	}
}