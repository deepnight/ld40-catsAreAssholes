import mt.heaps.slib.*;

class Assets {
	public static var cdbTiles : h2d.Tile;
	public static var gameElements : SpriteLib;
	public static function init() {
		cdbTiles = hxd.Res.cdbTiles.toTile();
		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
	}
}