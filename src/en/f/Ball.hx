package en.f;

import hxd.Key;

class Ball extends en.Furn {
	public function new(x,y) {
		super(x,y);
		radius = Const.GRID*0.3;
		weight = 0;
		frict = 0.97;
		bounceFrict = 1;
		gravity*=0.6;
		spr.anim.registerStateAnim("ballFlat",1,function() return cd.has("flat"));
		spr.anim.registerStateAnim("ball",0);
		spr.colorMatrix = dn.Color.getColorizeMatrixH2d(dn.Color.makeColorHsl(rnd(0,1),1,1), rnd(0.3,1));
		enableShadow(0.5);
	}

	override function onTouch(e:Entity) {
		super.onTouch(e);
		if( onGround ) {
			dx+=rnd(0,0.2,true);
			dy+=rnd(0,0.2,true);
			jump(rnd(0.6,1));
			Assets.SBANK.ball0(0.5);
			if( e.is(Cat) && e.as(Cat).isOnJob(Play(null)) )
				game.moneyMan.trigger(e, Ball);
		}
	}

	override function onTouchWallX() {
		dx*=-1;
	}

	override function onTouchWallY() {
		dy*=-1;
	}

	override function onBounce(pow:Float) {
		super.onBounce(pow);
		if( pow>=0.6 ) {
			Assets.SBANK.ball0(0.3);
			cd.setS("flat", 0.1*pow);
		}
		else
			Assets.SBANK.ball0(0.1);
	}

	override public function postUpdate() {
		super.postUpdate();
		//spr.visible = !Console.ME.has("screen");
		//shadow.visible = !Console.ME.has("screen");
	}
}