import mt.heaps.slib.*;

class Assets {
	public static var items : h2d.Tile;
	public static var cdbTiles : h2d.Tile;
	public static var gameElements : SpriteLib;
	public static var font : h2d.Font;

	public static function init() {
		font = hxd.Res.minecraftiaOutline.toFont();
		items = hxd.Res.items.toTile();
		cdbTiles = hxd.Res.cdbTiles.toTile();
		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
	}

	public static function getItem(k:Data.ItemKind) {
		return mt.deepnight.CdbHelper.getH2dTile(items, Data.item.get(k).icon);
	}
}