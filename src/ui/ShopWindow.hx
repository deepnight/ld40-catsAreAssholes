package ui;

import mt.MLib;
import mt.deepnight.Lib;
import mt.heaps.slib.*;
import hxd.Key;

class ShopWindow extends mt.Process {
	public static var ME : ShopWindow;
	var mask : h2d.Graphics;
	//var bg : h2d.ScaleGrid;
	var wFlow : h2d.Flow;
	var iFlow : h2d.Flow;
	var cursor : HSprite;
	var money : h2d.Text;

	var curIdx = 0;
	var items : Array<{ f:h2d.Flow, p:Int, cb:Void->Void } >;
	var door : en.inter.Door;

	public function new() {
		super(Main.ME);
		ME = this;

		door = en.inter.Door.ALL[0];

		createRootInLayers(Main.ME.root, Const.DP_UI);
		root.setScale(Const.SCALE);
		items = [];

		mask = new h2d.Graphics(root);
		tw.createS(mask.alpha, 0>1, 0.3);

		//bg = new h2d.ScaleGrid(Assets.gameElements.getTile("window"), 8,8, root);

		wFlow = new h2d.Flow(root);
		wFlow.padding = 8;
		wFlow.isVertical = true;
		wFlow.horizontalAlign = Middle;
		wFlow.backgroundTile = Assets.gameElements.getTile("window");
		wFlow.borderHeight = wFlow.borderWidth = 8;

		money = new h2d.Text(Assets.font, wFlow);
		money.textColor = 0xFF9900;
		wFlow.getProperties(money).paddingBottom = 8;

		iFlow = new h2d.Flow(wFlow);
		iFlow.isVertical = true;
		iFlow.verticalSpacing = 1;

		wFlow.addSpacing(8);
		var tf = new h2d.Text(Assets.font, wFlow);
		if( door.hasAnyEvent() )
			tf.text = "SPACE to continue";
		else
			tf.text = "SPACE to buy, ESCAPE to cancel";
		tf.textColor = 0x805337;

		cd.setS("lock", 0.2);
		refresh();
		onResize();
		tw.createS(wFlow.y, -wFlow.outerHeight>wFlow.y, 0.25);
		Game.ME.pause();
	}

	function refresh() {
		items = [];
		iFlow.removeChildren();

		if( door.hasAnyEvent() ) {
			money.visible = false;
			var tf = new h2d.Text(Assets.font, iFlow);
			tf.text = "Delivery in progress, you can't order anything for now.";
			//tf.text = "Livraison en cours, vous ne pouvez rien commander d'autre en attendant.";
			tf.maxWidth = 200;
		}
		else {
			for(i in Data.item.all) {
				if( i.cost!=null || i.scaledCosts.length>0 ) {
					if( i.maxBuy!=null ) {
						// Buy limit
						var n = 0;
						for(k in en.inter.Shop.ME.boughts)
							if(k==i.id)
								n++;
						if( n>=i.maxBuy )
							continue;
					}
					addItem(i.id);
				}
			}
		}

		cursor = Assets.gameElements.h_get("use",0, 0.5,0.5, iFlow);
		iFlow.getProperties(cursor).isAbsolute = true;
		cursor.rotation = 1.57;
		onResize();
	}

	function addItem(k:Data.ItemKind) {
		var inf = Data.item.get(k);
		var f = new h2d.Flow(iFlow);
		//f.debug = true;
		f.verticalAlign = Middle;
		f.horizontalSpacing = 4;
		f.backgroundTile = Assets.gameElements.getTile("box");
		f.borderHeight = f.borderWidth = 4;
		f.minWidth = 250;

		var icon = new h2d.Bitmap(Assets.getItem(k), f);
		icon.tile.setCenterRatio(0,0.25);


		var w = new h2d.Flow(f);
		w.minHeight = 2;
		w.minWidth = 40;
		w.horizontalAlign = Middle;
		var cost = inf.cost!=null ? inf.cost : 0;
		if( inf.scaledCosts.length>0 ) {
			var n = en.inter.Shop.ME.countPreviousBoughts(k);
			cost = inf.scaledCosts[ MLib.min(n, inf.scaledCosts.length-1) ].v;
		}
		if( cost>0 ) {
			var tf = new h2d.Text(Assets.font, w);
			tf.text = "$"+cost;
			tf.textColor = cost<=Game.ME.hero.money ? 0xFF9900 : 0xD20000;
		}
		else {
			var tf = new h2d.Text(Assets.font, w);
			tf.text = "FREE";
			tf.textColor = 0x8CD12E;
		}

		f.addSpacing(8);

		var tf = new h2d.Text(Assets.font, f);
		tf.text = inf.desc;
		tf.textColor = cost<=Game.ME.hero.money ? 0xFFFFFF : 0xE77272;

		items.push( {
			f:f,
			p:cost,
			cb:function() {
				en.inter.Shop.ME.boughts.push(k);
				door.addEvent( Deliver(k), #if debug 0 #else inf.deliveryS #end );
			},
		});
	}

	function getWid() return Boot.ME.s2d.width/Const.SCALE;
	function getHei() return Boot.ME.s2d.height/Const.SCALE;

	override public function onResize() {
		super.onResize();
		mask.clear();
		mask.beginFill(0x1B1137,0.75);
		mask.drawRect(0,0,getWid(),getHei());

		wFlow.reflow();
		wFlow.x = getWid()*0.5 - wFlow.outerWidth*0.5;
		wFlow.y = getHei()*0.5 - wFlow.outerHeight*0.5;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
		Game.ME.resume();
	}

	function close() {
		cd.setS("closing", 99999);
		tw.createS(root.alpha, 0, 0.1);
		tw.createS(wFlow.y, -wFlow.outerHeight,0.1).end( function() {
			destroy();
		});
	}

	override public function update() {
		if( Game.ME.destroyed )
			destroy();

		super.update();

		if( cd.has("closing") )
			return;

		money.text = "You have $"+Game.ME.hero.money;

		for(i in items)
			i.f.alpha = 0.7;
		var i = items[curIdx];
		cursor.visible = i!=null;
		if( i!=null ) {
			i.f.alpha = 1;
			cursor.x = 5 - MLib.fabs(Math.sin(ftime*0.2)*5);
			cursor.y += ( i.f.y + i.f.outerHeight*0.5 - cursor.y ) * 0.3;

			if( Key.isPressed(Key.DOWN) && curIdx<items.length-1 )
				curIdx++;

			if( Key.isPressed(Key.UP) && curIdx>0 )
				curIdx--;

			if( !cd.has("lock") && ( Key.isPressed(Key.ENTER) || Key.isPressed(Key.SPACE) ) ) {
				if( Game.ME.hero.money>=i.p ) {
					Game.ME.hero.money-=i.p;
					i.cb();
					close();
				}
			}
		}

		if( door.hasAnyEvent() && Key.isPressed(Key.SPACE) )
			close();

		if( Key.isPressed(Key.ESCAPE) )
			close();
	}
}

