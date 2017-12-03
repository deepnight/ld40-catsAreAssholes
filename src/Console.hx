import mt.MLib;

class Console extends h2d.Console {
	public static var ME : Console;

	var flags : Map<String,Bool>;
	public function new() {
		super(Assets.font);
		ME = this;
		Main.ME.root.add(this, Const.DP_UI);

		flags = new Map();
		#if debug
		//set("path",true);
		//set("job",true);
		#end

		#if debug
		this.addCommand("gold", [{ name:"v", t:AInt}], function(v:Int) {
			Game.ME.hero.money+=v;
			ui.Money.ME.blink();
			log("+$"+v, 0xFFFF00);
		});
		this.addCommand("set", [{ name:"k", t:AString }], function(k:String) {
			set(k,true);
			log("+ "+k, 0x80FF00);
		});
		this.addCommand("unset", [{ name:"k", t:AString, opt:true } ], function(?k:String) {
			if( k==null ) {
				log("Reset all.",0xFF0000);
				flags = new Map();
			}
			else {
				log("- "+k,0xFF8000);
				set(k,false);
			}
		});
		this.addAlias("+","set");
		this.addAlias("-","unset");
		#end
	}

	public function set(k:String,v) return flags.set(k,v);
	public function has(k:String) return flags.get(k)==true;
}