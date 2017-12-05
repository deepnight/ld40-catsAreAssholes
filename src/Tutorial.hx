import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Tweenie;

class Tutorial extends mt.Process {
	public static var ME : Tutorial;

	var done : Map<String,Bool>;
	public function new() {
		super(Game.ME);

		ME = this;
		done = new Map();
		cd.setS("lock",1);
	}

	public function complete(k:String) {
		done.set(k,true);
		if( ui.TutorialTip.ME!=null && ui.TutorialTip.ME.tutoId==k ) {
			cd.setS("lock",0.7);
			ui.TutorialTip.ME.close();
		}
	}

	public function tryToStart(k:String, str:String) {
		if( Game.ME.hero.isDead() )
			return false;

		if( cd.has("lock") )
			return false;

		if( ui.TutorialTip.ME!=null )
			return false;

		if( done.exists(k) )
			return false;

		done.set(k,true);
		new ui.TutorialTip(k, str);
		return true;
	}

	public function hasDone(k:String) return done.exists(k);

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}
}
