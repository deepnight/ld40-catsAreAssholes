import mt.heaps.slib.*;

class Assets {
	public static var cdbTiles : h2d.Tile;
	public static var gameElements : SpriteLib;
	public static var font : h2d.Font;

	public static function init() {
		font = hxd.Res.minecraftiaOutline.toFont();
		cdbTiles = hxd.Res.cdbTiles.toTile();
		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
	}
}