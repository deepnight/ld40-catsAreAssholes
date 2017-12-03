package ui;

import mt.MLib;
import mt.deepnight.Lib;
import mt.heaps.slib.*;
import hxd.Key;

class ShopWindow extends mt.Process {
	var mask : h2d.Graphics;
	//var bg : h2d.ScaleGrid;
	var wFlow : h2d.Flow;
	var iFlow : h2d.Flow;
	var cursor : HSprite;
	var money : h2d.Text;

	var curIdx = 0;
	var items : Array<{ f:h2d.Flow, p:Int, cb:Void->Void } >;

	public function new() {
		super(Main.ME);

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
		wFlow.addSpacing(8);

		iFlow = new h2d.Flow(wFlow);
		iFlow.isVertical = true;

		wFlow.addSpacing(8);
		var tf = new h2d.Text(Assets.font, wFlow);
		tf.text = "ESCAPE to cancel";
		tf.textColor = 0x805337;

		cd.setS("lock", 0.2);
		refresh();
		onResize();
		tw.createS(wFlow.y, -wFlow.outerHeight>wFlow.y, 0.25);
		Game.ME.pause();
	}

	function refresh() {
		items = [];
		var door = en.inter.Door.ALL[0];
		iFlow.removeChildren();

		if( door.hasAnyEvent() ) {
			var tf = new h2d.Text(Assets.font, iFlow);
			tf.text = "Delivery in progress, you can't order anything for now.";
			//tf.text = "Livraison en cours, vous ne pouvez rien commander d'autre en attendant.";
			tf.maxWidth = 200;
		}
		else {
			addItem( Assets.getItem(FoodBox), "Fish refill for the fridge", 10, function() {
				door.addEvent( Deliver(FoodBox), 10 );
			} );
			addItem( Assets.getItem(CatBox), "A new cat!", 30, function() {
				door.addEvent( Deliver(CatBox), 10 );
			} );
			addItem( Assets.getItem(TrayBox), "Extra bowl", 30, function() {
				door.addEvent( Deliver(TrayBox), 20 );
			} );
		}

		cursor = Assets.gameElements.h_get("use",0, 0.5,0.5, iFlow);
		iFlow.getProperties(cursor).isAbsolute = true;
		cursor.rotation = 1.57;
		onResize();
	}

	function addItem(t:h2d.Tile, str:String, cost:Int, cb:Void->Void) {
		var f = new h2d.Flow(iFlow);
		f.verticalAlign = Middle;
		f.horizontalSpacing = 4;

		var icon = new h2d.Bitmap(t, f);

		var w = new h2d.Flow(f);
		w.minWidth = 50;
		var tf = new h2d.Text(Assets.font, w);
		tf.text = "$"+cost;
		tf.textColor = 0xFF9900;

		f.addSpacing(8);

		var tf = new h2d.Text(Assets.font, f);
		tf.text = str;

		items.push( {
			f:f,
			p:cost,
			cb:cb,
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
		super.update();
		if( cd.has("closing") )
			return;

		money.text = "You have $"+Game.ME.hero.money;

		var i = items[curIdx];
		cursor.visible = i!=null;
		if( i!=null ) {
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


		if( Key.isPressed(Key.ESCAPE) )
			close();
	}
}

