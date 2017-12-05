import mt.heaps.slib.*;
import mt.deepnight.Sfx;

class Assets {
	public static var SBANK = Sfx.importDirectory("sfx");
	public static var items : h2d.Tile;
	public static var cdbTiles : h2d.Tile;
	public static var gameElements : SpriteLib;
	public static var font : h2d.Font;
	public static var music : Sfx;

	public static function init() {
		Sfx.setGroupVolume(0, 1);
		Sfx.setGroupVolume(1, 0.4);
		music = Assets.SBANK.jazz();
		music.playOnGroup(1,true);

		font = hxd.Res.minecraftiaOutline.toFont();
		items = hxd.Res.items.toTile();
		cdbTiles = hxd.Res.cdbTiles.toTile();
		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");

		gameElements.defineAnim("heroTalk", "0,1,2(2),1,0,1,0,2,1(2),2,0,1(2),2,0,2");
		gameElements.defineAnim("heroRoll", "0");
		gameElements.defineAnim("heroWalk", "0(2),1,2,3,4(2),3,2,1");


		gameElements.defineAnim("sideWalk", "0(2),1,2(2),1");
		gameElements.defineAnim("sideIdleTv", "0,1,2(2),1(3),2,1,0(2),2,1,0,2(2),1,0,1,0");


		gameElements.defineAnim("bcatObserve", "0(10),1,2(16),1");
		gameElements.defineAnim("ncatObserve", "0(10),1,2(16),1");
		gameElements.defineAnim("wcatObserve", "0(10),1,2(16),1");

		gameElements.defineAnim("bcatShit", "0(2),1,2(3),1");
		gameElements.defineAnim("ncatShit", "0(2),1,2(3),1");
		gameElements.defineAnim("wcatShit", "0(2),1,2(3),1");

		gameElements.defineAnim("bcatDash", "0(2),1");
		gameElements.defineAnim("ncatDash", "0(2),1");
		gameElements.defineAnim("wcatDash", "0(2),1");

		gameElements.defineAnim("bcatEat", "0(2),1,0, 1,2, 1,2, 1,2(2)");
		gameElements.defineAnim("ncatEat", "0(2),1,0, 1,2, 1,2, 1,2(2)");
		gameElements.defineAnim("wcatEat", "0(2),1,0, 1,2, 1,2, 1,2(2)");

		gameElements.defineAnim("bcatLick", "0-2(1), 3(2)");
		gameElements.defineAnim("ncatLick", "0-2(1), 3(2)");
		gameElements.defineAnim("wcatLick", "0-2(1), 3(2)");

	}

	public static function getItem(k:Data.ItemKind) {
		return mt.deepnight.CdbHelper.getH2dTile(items, Data.item.get(k).icon);
	}
}