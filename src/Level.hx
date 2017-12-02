import mt.deepnight.CdbHelper;

class Level extends mt.Process {
	var lInfos : Data.LevelMap;
	var bg : h2d.TileGroup;
	var collMap : Map<Int,Bool>;
	public var wid : Int;
	public var hei : Int;

	public function new(id:Data.LevelMapKind) {
		super(Game.ME);

		lInfos = Data.levelMap.get(id);
		collMap = new Map();
		wid = lInfos.width;
		hei = lInfos.height;

		createRootInLayers(Game.ME.root, Const.DP_BG);
		var sheet = hxd.Res.cdbTiles.toTile();
		bg = new h2d.TileGroup(sheet, root);

		for(l in lInfos.layers) {
			var tileSet = lInfos.props.getTileset(Data.levelMap, l.data.file);
			var tiles = CdbHelper.getLayerTiles(l.data, sheet, lInfos.width, tileSet);

			if( l.name=="coll" ) {
				// Collisions
				for(t in tiles)
					collMap.set(coordToId(t.cx,t.cy), true);
			}
			else {
				// Tiles
				for(t in tiles)
					bg.add(t.x, t.y, t.t);
			}
		}
	}

	public inline function hasColl(cx:Int, cy:Int) {
		return isValid(cx,cy) ? collMap.get( coordToId(cx,cy) )==true : true;
	}

	public inline function isValid(cx:Int,cy:Int) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}
	public inline function coordToId(cx:Int,cy:Int) return cx+cy*wid;

	override public function onDispose() {
		super.onDispose();
		bg.remove();
	}
}
