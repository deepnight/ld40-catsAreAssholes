import mt.heaps.slib.*;
import mt.deepnight.Sfx;

class Assets {
	public static var SBANK = Sfx.importDirectory("sfx");
	public static var items : h2d.Tile;
	public static var cdbTiles : h2d.Tile;
	public static var gameElements : SpriteLib;
	public static var font : h2d.Font;

	public static function init() {
		Sfx.setGroupVolume(0,1);
		Sfx.setGroupVolume(1,0.2);
		//music = Assets.SBANK.music();
		//music.playOnGroup(1,true);
		//#if js
		//Sfx.muteGroup(0);
		//Sfx.muteGroup(1);
		//#end

		font = hxd.Res.minecraftiaOutline.toFont();
		items = hxd.Res.items.toTile();
		cdbTiles = hxd.Res.cdbTiles.toTile();
		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
	}

	public static function getItem(k:Data.ItemKind) {
		return mt.deepnight.CdbHelper.getH2dTile(items, Data.item.get(k).icon);
	}
}