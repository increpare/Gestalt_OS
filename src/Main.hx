import haxe.rtti.XmlParser;
import haxe.ds.Vector;
import haxegon.*;
import utils.*;
import StringTools;
import haxe.Serializer;
import haxe.Unserializer;
import lime.ui.Window;
import haxe.Json;
#if html5
 import js.Browser;
 import js.html.Audio;
#end

@:access(lime.ui.Window)

class AnimationFrame {
	public var vor_brett:Array<Array<String>>;
	public var nach_brett:Array<Array<String>>;
	public var abweichung:Array<Array<Int>>;
	public var maxabweichung:Int;
	public function new(){
		
	}
}



class LevelZustand{
	public var i:Array<Array<String>>;
	public var sp:Array<Array<String>>;
	public var hash:String;
	public function new(){};
}

class Ziel{
	public var ziel:Array<Array<String>>;
	public var werkzeuge:Array<Bool>;
	public function new(z:Array<Array<String>>,wz:Array<Bool>){
		ziel=z;
		werkzeuge=wz;
	}
}

class Main {

	public var letztes_hoverziel_x:Int=-1;
	public var letztes_hoverziel_y:Int=-1;
	public var cansolve:Bool=true;
	public var solvex:Int=-1;
	public var solvey:Int=-1;

	public var editmodus:Bool=false;
	public var editor_tl_x:Int=1;
	public var editor_tl_y:Int=2;
	public var editor_br_x:Int=4;
	public var editor_br_y:Int=5;


	public var aktuellesZiel:Ziel;	
	public var aktuellesZielIdx=0;
	public var ziele:Array<Array<String>> = [

	
		//1 sehr einfach
		["v1","cy4:Ziely4:zielaau6hany2:s5R2R2R2nhau6hhy9:werkzeugeatttttttttttttttttttthg"],

		//2
		["v1","cy4:Ziely4:zielaau5hany2:s9u3hau5hau3R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//3 leichter variatn von 2x4 punkte
		["v1","cy4:Ziely4:zielaau5hany3:s10nR2nhau5hanR2nR2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//4 mittel-leicht, interessanter
		["v1","cy4:Ziely4:zielaay2:s5R2R2haR2y3:s14R2haR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//5 ziemlich einfach 
		["v1","cy4:Ziely4:zielaay3:s12R2nR2R2haR2nR2nR2hanR2y2:s8R2nhaR2nR2nR2haR2R2nR2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//6 ziemlich einfach - zu einfach?
		["v1","cy4:Ziely4:zielaay3:s12R2R2R2R2haR2nR2nR2haR2R2R2R2R2haR2nR2nR2haR2R2R2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//7 mittel-leicht, nicht so interessant
		["v1","cy4:Ziely4:zielaay2:s5u3R2haR2y3:s12R3R3R2haR2R3nR3R2haR2R3R3R3R2haR2u3R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//8 2x4 punkte
		["v1","cy4:Ziely4:zielaau5hany3:s10nR2nhau5hanR2nR2nhau5hanR2nR2nhau5hanR2nR2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//9 finde ich das tatsächlich ok? ich weiß nicht!
		["v1","cy4:Ziely4:zielaau5hany2:s5u3hau2R2u2hau3R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//10 große 1 (nicht so gut)
		["v1","cy4:Ziely4:zielaay3:s12R2nhanR2nhanR2nhanR2nhaR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//11 sollte nicht zu schwierig sein, aber bin nicht sicher
		["v1","cy4:Ziely4:zielaay2:s9R2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//12 kreuz mit beharrung
		["v1","cy4:Ziely4:zielaany2:s2nhaR2nR2hanR2nhhy9:werkzeugeatttttttttttttttttttthg"],

		//13 avocadenvoll
		["v1","cy4:Ziely4:zielaay3:s21R2R2R2haR2R2R2R2haR2R2R2R2haR2R2R2R2haR2R2R2R2haR2R2R2R2haR2R2R2R2haR2R2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],


		//43 hexagon
		["v1","cy4:Ziely4:zielaau2y2:s8u2haR2u3R2hau5haR2u3R2hau2R2u2hhy9:werkzeugeatttttttttttttttttttthg"],


		//14 humdrumm
		["v1","cy4:Ziely4:zielaau5hany3:s10y3:s11R2nhany2:s5R4R4nhanR2R3R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//15 langweilig, mit avocaden
		["v1","cy4:Ziely4:zielaay3:s20y3:s21R2haR3nR3haR2R3R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//16 L mit füßen
		["v1","cy4:Ziely4:zielaau5hany2:s5u3hanR2u3hanR2R2R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//17 herzen - nicht einfach aber macht spaß?
		["v1","cy4:Ziely4:zielaany2:s2nR2nhaR2nR2nR2hanR2nR2nhau2R2u2hhy9:werkzeugeatttttttttttttttttttthg"],

		//18  drehen
		["v1","cy4:Ziely4:zielaau5hau2y3:s11u2hany3:s10nR2nhau2R3u2hau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//39 leg diagonal. fun
		["v1","cy4:Ziely4:zielaay2:s5u3hanR2u2hau2R2nhau3R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//19  vierekige haut
		["v1","cy4:Ziely4:zielaau5hany2:s2R2R2nhanR2nR2nhanR2R2R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//20 ziemlich einfach , digit 3 zu machen
		["v1","cy4:Ziely4:zielaay3:s12R2R2hau2R2hanR2R2hau2R2haR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//21 große digit 5 (vllt besser ohne grenzebereich?)
		["v1","cy4:Ziely4:zielaau5hany3:s12R2R2nhanR2u3hanR2R2R2nhau3R2nhanR2R2R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//22 cross with ups and downs
		["v1","cy4:Ziely4:zielaau5hau2y3:s17u2hany3:s16nR3nhau2R2u2hau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//23 mittel-schwer, könnte spaß machen
		["v1","cy4:Ziely4:zielaany2:s5nR2haR2nR2nhanR2nR2haR2nR2nhanR2nR2haR2nR2nhanR2nR2hhy9:werkzeugeatttttttttttttttttttthg"],

		//24 2x2 deleters
		["v1","cy4:Ziely4:zielaau4hany2:s1y2:s3nhany2:s4y3:s19nhau4hhy9:werkzeugeatttttttttttttttttttthg"],

		//42 avocado plant
		["v1","cy4:Ziely4:zielaau5hau2y3:s21u2hanR2R2R2nhau2R2u2hau2y3:s20u2hau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//25 2x2 suckers
		["v1","cy4:Ziely4:zielaau4hany2:s8R2nhanR2R2nhau4hhy9:werkzeugeatttttttttttttttttttthg"],

		//26 4x4 pushers
		["v1","cy4:Ziely4:zielaay3:s13u2R2hau4hau4haR2u2R2hhy9:werkzeugeatttttttttttttttttttthg"],


		//27 quite tricky , by my logic it requires credoing a copier
		["v1","cy4:Ziely4:zielaau5hany3:s10y3:s11R2nhany3:s18nR4nhanR2R3R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],


		//28 vertical avod/dropper ladder
		["v1","cy4:Ziely4:zielaay3:s21hay2:s9haR2haR3haR2haR3haR2hhy9:werkzeugeatttttttttttttttttttthg"],

		//29 4x4 fill a hole
		["v1","cy4:Ziely4:zielaay2:s6R2R2R2haR2u2R2haR2u2R2haR2R2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//36 great avocado level
		["v1","cy4:Ziely4:zielaau3hany3:s21nhau3hanR2nhany3:s20nhau3hhy9:werkzeugeatttttttttttttttttttthg"],


		//30 3x3 skin
		["v1","cy4:Ziely4:zielaay2:s2R2R2haR2R2R2haR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//31 spaced ladder of flippers
		["v1","cy4:Ziely4:zielaany3:s16nhau3hanR2nhau3hanR2nhau3hanR2nhau3hanR2nhhy9:werkzeugeatttttttttttttttttttthg"],

		//32 pretty easy-going
		["v1","cy4:Ziely4:zielaau2y3:s10u2hau5haR2nR2nR2hau5hau2R2u2hhy9:werkzeugeatttttttttttttttttttthg"],

		//41  two col level that looks like the old toolbar
		["v1","cy4:Ziely4:zielaay2:s2R2hay2:s5R3hay3:s12R4hay2:s6R5haR2R2haR3R3haR4R4haR5R5hhy9:werkzeugeatttttttttttttttttttthg"],

		//33 medium-interesting, but not bad
		["v1","cy4:Ziely4:zielaay3:s15nR2hanR2nhaR2nR2hhy9:werkzeugeatttttttttttttttttttthg"],

		//34 tricky-hard to guess at (Actually i think it's ok now)
		["v1","cy4:Ziely4:zielaany3:s11nR2nhau5hay3:s10R2R3R2R3hhy9:werkzeugeatttttttttttttttttttthg"],

		//35 +made of turners. it's ok
		["v1","cy4:Ziely4:zielaay3:s14nR2hanR2nhaR2nR2hhy9:werkzeugeatttttttttttttttttttthg"],

		//37 avocado surrounded by foliage
		["v1","cy4:Ziely4:zielaay3:s21R2R2haR2y3:s20R2haR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//38 = of plusses, designed to force plussing a plus
		["v1","cy4:Ziely4:zielaau5hany2:s7R2R2nhau5hanR2R2R2nhau5hhy9:werkzeugeatttttttttttttttttttthg"],

		//40 quad with corners missing
		["v1","cy4:Ziely4:zielaany3:s12R2nhaR2u2R2haR2u2R2hanR2R2nhhy9:werkzeugeatttttttttttttttttttthg"],

		///these need to be moved begin

		//44 make a 2
		["v1","cy4:Ziely4:zielaay3:s21R2R2hau2R2haR2R2R2haR2u2haR2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//45  filled skin
		["v1","cy4:Ziely4:zielaany2:s2R2R2nhaR2y2:s6R3R3R2haR2R3R2R3R2haR2R3R3R3R2hanR2R2R2nhhy9:werkzeugeatttttttttttttttttttthg"],

		//46 tricksy double-snake
		["v1","cy4:Ziely4:zielaau2y3:s12R2R2hau2R2nR2haR2R2R2R2R2haR2nR2u2haR2R2R2u2hhy9:werkzeugeatttttttttttttttttttthg"],


		//these need to be placed end

		//47 designated penultimate level
		["v1","cy4:Ziely4:zielaay2:s6R2R2R2R2haR2u3R2haR2nR2nR2haR2u3R2haR2R2R2R2R2hhy9:werkzeugeatttttttttttttttttttthg"],

		//48 amazong recreate palette level
		["v1","cy4:Ziely4:zielaay3:s12y2:s1y2:s7y2:s3hay3:s14y2:s6y3:s11y2:s4hay3:s18y2:s5y3:s13y3:s10hay2:s2y2:s8y3:s20y2:s9hay3:s15y3:s17y3:s16y3:s19hhy9:werkzeugeatttttttttttttttttttthg"],

		//49 SPECIAL empty level
		["v1","cy4:Ziely4:zielaau3hau3hau3hhy9:werkzeugeatttttttttttttttttttthg"],

		//50 special level tower
		["v1","cy4:Ziely4:zielaau3hau3hau3hhy9:werkzeugeatttttttttttttttttttthg"],
	];



	private function do_playSound(s:Int){
		if (Globals.state.audio==0){
			return;
		}
		// switch(s){
		// 	case 0://animation sound
		// 		_sfx_drop.play();
		// 	case 1://remove
		// 		_sfx_drop2.play();
		// 	case 2://drop
		// 		_sfx_drop3.play();
		// 	case 3://drag begin
		// 		_sfx_drop2.play();
		// }
	}

	public function leererAbweichungsgitter():Array<Array<Int>>{
		var result = new Array<Array<Int>>();
		for (j in 0...sp_zeilen){
			var zeile = new Array<Int>();
			for (i in 0...sp_spalten){
				var index = i+sp_spalten*j+1 ;
				zeile.push(-1);
			}
			result.push(zeile);
		} 
		return result;
	}

	public var i_spalten:Int=4;
	public var i_zeilen:Int=5;
	
	public var sp_spalten:Int=10;
	public var sp_zeilen:Int=11;
	

	public var szs_inventory:Array<Array<String>>;
	public var szs_brett:Array<Array<String>>;


	public var animationen:Array<AnimationFrame>;
	public var zieh_modus:Bool;
	public var zieh_quelle_i:Int;
	public var zieh_quelle_j:Int;	
	public var zieh_offset_x:Int;
	public var zieh_offset_y:Int;
	public var zieh_name:String;
	
	function checkSolve(partikelnErlauben:Bool){
		var schonloesbar = cansolve;

		solvex=-1;
		solvey=-1;
		cansolve=false;
		
		if (geloest[aktuellesZielIdx]==ziele[aktuellesZielIdx][0]){
			return;
		}

		if (aktuellesZielIdx==48){
			cansolve=true;

			for (j in 0...sp_zeilen){
				for (i in 0...sp_spalten){
					if (szs_brett[j][i]!=null){
						cansolve=false;
						return;
					}
				}
			}

			for (j in 0...i_zeilen){
				for (i in 0...i_spalten){
					if (szs_inventory[j][i]!=null){
						cansolve=false;
						return;
					}
				}
			}
					
		} else if (aktuellesZielIdx==49){
			cansolve=true;
			for (i in 0...(ziele.length-1)){
				if (geloest[i]==ziele[i][0]){
					cansolve=false;
					return;
				}
			}
		} else {
			var z =  aktuellesZiel.ziel;
			var zw = aktuellesZiel.ziel[0].length;
			var zh = aktuellesZiel.ziel.length;

			for (gi in 0...(sp_spalten+1-zw)){
				for (gj in 0...(sp_zeilen+1-zh)){
					var match=true;
					for (i in 0...zw){
						for (j in 0...zh){
							if (z[j][i]!=szs_brett[gj+j][gi+i]){
								match=false;
							}
						}
						if (match==false){
							break;
						}
					}
					if (match){
						cansolve=true;
						solvex=gi;
						solvey=gj;
						break;
					}
				}	
			}
		}

		if (partikelnErlauben && cansolve && schonloesbar==false){
			var px = 306;
			var py =  182;
			var pbb = Gfx.imagewidth("btn_solve_bg_up");
			var pbh = Gfx.imageheight("btn_solve_bg_down");
			cansolve=true;
			Particle.GenerateParticles(
							{min:px,max:px+pbb},
							{min:py,max:py+pbh},
							0x9e61cc,
							10,
							1.0,
							0.0,
							{min:2,max:4},
							{min:0,max:360},
							{min:-20,max:20},
							{min:-20,max:20},
							{min:-1,max:1},
							{min:3,max:5},
							{min:0,max:0});	
			Particle.GenerateParticles(
							{min:px,max:px+pbb},
							{min:py,max:py+pbh},
							0x6051ac,
							10,
							1.0,
							0.0,
							{min:2,max:4},
							{min:0,max:360},
							{min:-20,max:20},
							{min:-20,max:20},
							{min:-1,max:1},
							{min:3,max:5},
							{min:0,max:0});	
			Particle.GenerateParticles(
							{min:px,max:px+pbb},
							{min:py,max:py+pbh},
							0x40318d,
							10,
							1.0,
							0.0,
							{min:2,max:4},
							{min:0,max:360},
							{min:-20,max:20},
							{min:-20,max:20},
							{min:-1,max:1},
							{min:3,max:5},
							{min:0,max:0});	
							
		}
	}
	
	

	function LoadLevel(level:Int){
		if (level>=ziele.length||level<0){
			aktuellesZiel = new Ziel(
				[[null]],
				[
					true,true,
					true,true,
					true,true,
					true,true,
					true,true,
					true,true,
					true,true,
					true,true,
					true,true,
					true,true
				]
			);

			neuesBlatt();
			checkSolve(false);
			forcerender=true;
			return;
		}

		aktuellesZielIdx=level;

		Save.savevalue("mwb"+version+"levelidx",aktuellesZielIdx);
		var ziel_s = ziele[aktuellesZielIdx][1];
	    var unserializer = new Unserializer(ziel_s);

		aktuellesZiel = unserializer.unserialize();

		var dieser_undoStack = undoStack[aktuellesZielIdx];
		var dieser_undoStack_pos = undoPos[aktuellesZielIdx];
		if (dieser_undoStack.length>0){
			var zs = dieser_undoStack[dieser_undoStack_pos];
			szs_inventory=Copy.copy(zs.i);
			szs_brett=Copy.copy(zs.sp);
		} else {
			neuesBlatt();
		}

		checkSolve(false);
		forcerender=true;
	}
	
		
	var geloest:Array<String> = [];
	var version=1.4;
	
	// function _setupSound(url:String, ?loop:Bool = false):WaudSound {
	// 	// return  new WaudSound(
	// 		url, { autoplay: false, loop: loop, volume: 1.0 });
	// }

	// var _sfx_drop:WaudSound;
	// var _sfx_drop2:WaudSound;
	// var _sfx_drop3:WaudSound;
	// var _sfx_drop4:WaudSound;

	function setup(){
		// Waud.init();
		// _sfx_drop = _setupSound("data/sounds/drop.mp3");
		// _sfx_drop2 = _setupSound("data/sounds/drop2.mp3");
		// _sfx_drop3 = _setupSound("data/sounds/drop3.mp3");
		// _sfx_drop4 = _setupSound("data/sounds/drop4.mp3");

		
		geloest = [];
		for (i in 0...ziele.length){
			geloest.push(Save.loadvalue("level"+version+"-"+i,null));
		}

		// Core.showstats=true;
		Core.fps=30;
		Gfx.clearcolor=Col.TRANSPARENT;

		undoStack=new Array<Array<LevelZustand>>();
		undoPos = new Array<Int>();
		for (i in 0...ziele.length){
			undoStack.push([]);
			undoPos.push(-1);
		}

		Globals.state.level=Save.loadvalue("mwblevel",0);
		Globals.state.audio=Save.loadvalue("mwbaudio",1);
		Globals.state.sprache=Save.loadvalue("mwbsprache_v2",1);

		for(i in 0...6){
			Globals.state.solved[i]=Save.loadvalue("mwbsolved"+i,0);
		}


		aktuellesZielIdx = Save.loadvalue("mwb"+version+"levelidx",0);
		Globals.state.level=aktuellesZielIdx;
		
		LoadLevel(Globals.state.level);	

		Core.fullscreenbutton(isFullscreenButtonPressed,326,209,Gfx.imagewidth("taste_t_bg_up"),Gfx.imageheight("taste_t_bg_up"));
	}


	function isFullscreenButtonPressed():Bool{
		return IMGUI.isButtonDown("vollbildmodus");
	}
	function reset(){
		setup();
	}

	public static var animFrameDauer:Int=5;
	public static var animPos:Int=0;

	function spazieren(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
		var xmin = hoverziel_x+1;
		var xmax_p1 = sp_spalten;
		var i=0;
		for (x in xmin...xmax_p1){
			if (anim.nach_brett[hoverziel_y][x]!=null){
				break;
			}
			i++;
			anim.nach_brett[hoverziel_y][x]="s5";
			anim.abweichung[hoverziel_y][x]=i;
		}
		anim.maxabweichung=i;
	}


	function spiegelkopien(anim:AnimationFrame,x:Int,y:Int){




			var startframe2 = new AnimationFrame();
			startframe2.vor_brett = Copy.copy(szs_brett);
			startframe2.nach_brett = Copy.copy(szs_brett);
			startframe2.abweichung = leererAbweichungsgitter();
			var anim2 = startframe2;
			startframe2.abweichung[y][x]=0;
			animationen.push(anim2);
			
			

		

		function get_vorbrett(px,py){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return null;
			}
			return anim.vor_brett[py][px];
		}


		function set_brett(px,py,v){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return;
			}
			anim2.nach_brett[py][px]=v;
		}


		function setf(px,py,v){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return;
			}
			anim.abweichung[py][px]=v;
			anim2.abweichung[py][px]=v;
		}


		var vn=get_vorbrett(x,y-1);
		var vs=get_vorbrett(x,y+1);
		var vo=get_vorbrett(x+1,y);
		var vw=get_vorbrett(x-1,y);

		setf(x-1,y,0);
		setf(x+1,y,0);
		setf(x,y-1,0);
		setf(x,y+1,0);

		if (vn==null){
			set_brett(x,y-1,vs);
		}

		if (vs==null){
			set_brett(x,y+1,vn);
		}

		if (vw==null){
			set_brett(x-1,y,vo);
		}

		if (vo==null){
			set_brett(x+1,y,vw);
		}

		anim.maxabweichung=0;
		anim2.maxabweichung=0;
	}


	function zeile_entleeren(anim:AnimationFrame,x:Int,y:Int){

		var max_frame=0;

		for (i in 1...sp_spalten){
			var i_von=x-i;
			var i_zu=x+i;
			if (i_von>=0 && i_von<sp_spalten){
				anim.nach_brett[y][i_von]=null;
				anim.abweichung[y][i_von]=i;
				if (i>max_frame){
					max_frame=i;
				}
			}
			if (i_zu>=0 && i_zu<sp_spalten){
				anim.nach_brett[y][i_zu]=null;
				anim.abweichung[y][i_zu]=i;
				if (i>max_frame){
					max_frame=i;
				}
			}
		}
		anim.maxabweichung=max_frame;
	}



	function wiederholen(anim:AnimationFrame,x:Int,y:Int){

		if (x==0){
			return;
		}

		var a = anim.nach_brett;
		var f = anim.abweichung;
		
		f[y][x-1]=1;
		anim.maxabweichung=1;

		tuePlatzierung(x-1,y,a[y][x-1],false);
		
	}




	function bomben(anim:AnimationFrame,x:Int,y:Int){


		var a = anim.nach_brett;
		var f = anim.abweichung;
		
		function entleeren(px,py){
			if (px<0||py<0||px>=sp_spalten||py>=sp_zeilen){
				return;
			}
			a[py][px]=null;
			f[py][px]=1;
		}

		entleeren(x-1,y-1);
		entleeren(x+0,y-1);
		entleeren(x+1,y-1);
		
		entleeren(x-1,y+0);
		entleeren(x+1,y+0);

		entleeren(x-1,y+1);
		entleeren(x+0,y+1);
		entleeren(x+1,y+1);

		anim.maxabweichung=1;
	}



	function spalte_entleeren(anim:AnimationFrame,x:Int,y:Int){

		var max_frame=0;

		for (j in 1...sp_zeilen){
			var j_von=y-j;
			var j_zu=y+j;
			if (j_von>=0 && j_von<sp_zeilen){
				anim.nach_brett[j_von][x]=null;
				anim.abweichung[j_von][x]=j;
				if (j>max_frame){
					max_frame=j;
				}
			}
			if (j_zu>=0 && j_zu<sp_zeilen){
				anim.nach_brett[j_zu][x]=null;
				anim.abweichung[j_zu][x]=j;
				if (j>max_frame){
					max_frame=j;
				}
			}
		}
		anim.maxabweichung=max_frame;
	}


	function schieben(anim:AnimationFrame,x:Int,y:Int){
		
		var a = anim.nach_brett;
		var f = anim.abweichung;
		
		f[y][x]=0;

		var frame=0;
		
		var dx=0;
		var dy=0;

		var i=0;


		//von links
		i=0;
		dx=0;
		while (dx<x){

			if (dx>0){
				a[y][dx-1]=a[y][dx];
			}
			a[y][dx]=null;
			f[y][dx]=i;
			dx++;
			i++;
		}
		i--;
		if (i>frame){
			frame=i;
		}


		//von rechts
		i=0;
		dx=sp_spalten-1;
		while (dx>x){

			if (dx<sp_spalten-1){
				a[y][dx+1]=a[y][dx];
			}
			a[y][dx]=null;
			f[y][dx]=i;
			dx--;
			i++;
		}
		i--;
		if (i>frame){
			frame=i;
		}



		//von oben
		i=0;
		dy=0;
		while (dy<y){

			if (dy>0){
				a[dy-1][x]=a[dy][x];
			}
			a[dy][x]=null;
			f[dy][x]=i;
			dy++;
			i++;
		}
		i--;
		if (i>frame){
			frame=i;
		}


		//von unten
		i=0;
		dy=sp_zeilen-1;
		while (dy>y){

			if (dy<sp_zeilen-1){
				a[dy+1][x]=a[dy][x];
			}
			a[dy][x]=null;
			f[dy][x]=i;
			dy--;
			i++;
		}
		i--;
		if (i>frame){
			frame=i;
		}

	

		anim.maxabweichung=frame;
	}



	function drehen(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;
		
		f[y][x]=0;


		function set_brett(px,py,v){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return;
			}
			anim.nach_brett[py][px]=v;
		}
		
		function get_vorbrett(px,py){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return null;
			}
			return anim.vor_brett[py][px];
		}


		function setf(px,py,v){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return;
			}
			f[py][px]=v;
		}
		

		function getf(px,py,def){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return def;
			}
			return f[py][px];
		}

		function von_bis(x1,y1,x2,y2,f):Bool{
			set_brett(x2,y2,get_vorbrett(x1,y1));
			setf(x2,y2,f);
			return true;
		}

		von_bis(x,y-1,		x-1,y-1,	1);
		von_bis(x-1,y-1,	x-1,y,		1);
		von_bis(x-1,y,		x-1,y+1,	1);
		von_bis(x-1,y+1,	x,y+1,		1);
		von_bis(x,y+1,		x+1,y+1,	1);
		von_bis(x+1,y+1,	x+1,y,		1);
		von_bis(x+1,y,		x+1,y-1,	1);
		von_bis(x+1,y-1,	x,y-1,		1);
		
		anim.maxabweichung=1;
	}


	function ziehen(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;
		
		a[y][x]="s8";
		f[y][x]=0;

		var frame=0;

		for (i in 1...sp_spalten){
			var x_l = x-i;
			var x_r = x+i;

			if (x_l>=0){
				if (i>1){
					a[y][x_l+1]=a[y][x_l];
				}
				a[y][x_l]=null;
				f[y][x_l]=i;
				if (i>frame){
					frame=i;
				}
			}

			if (x_r<sp_spalten){
				if (i>1){
					a[y][x_r-1]=a[y][x_r];
				}
				a[y][x_r]=null;
				f[y][x_r]=i;
				if (i>frame){
					frame=i;
				}
			}
		}


		for (j in 1...sp_zeilen){
			var y_t = y-j;
			var y_b = y+j;

			if (y_t>=0){
				if (j>1){
					a[y_t+1][x]=a[y_t][x];
				}
				a[y_t][x]=null;
				f[y_t][x]=j;
				if (j>frame){
					frame=j;
				}
			}

			if (y_b<sp_zeilen){
				if (j>1){
					a[y_b-1][x]=a[y_b][x];			
				}
				a[y_b][x]=null;
				f[y_b][x]=j;
				if (j>frame){
					frame=j;
				}
			}
		}

		anim.maxabweichung=frame;
	}

	function fuellen(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;
		//1 s6 ersetzen
		for (j in 0...sp_zeilen){
			for (i in 0...sp_spalten){
				if (a[j][i]=="s6"){
					a[j][i]="temp";
				}
			}
		}
		a[y][x]="s6";
		f[y][x]=0;
		var aenders=true;
		var frame=1;
		while (aenders){
			aenders=false;

			for (j in 0...sp_zeilen){
				for (i in 0...sp_spalten){
					var n = a[j][i];
					if (n!=null){
						continue;
					}
					var fuellbar=false;
					if (j>0 && a[j-1][i]=="s6" && f[j-1][i]==(frame-1)){
						fuellbar=true;
					} else if (j<sp_zeilen-1 && a[j+1][i]=="s6"&& f[j+1][i]==(frame-1)){
						fuellbar=true;
					} else if (i>0 && a[j][i-1]=="s6" && f[j][i-1]==(frame-1)){
						fuellbar=true;
					} else if (i<sp_spalten-1 && a[j][i+1]=="s6"&& f[j][i+1]==(frame-1)){
						fuellbar=true;
					}
					if (fuellbar){
						aenders=true;
						a[j][i]="s6";
						f[j][i]=frame;
					}
				}
			}
			frame++;
		}

		for (j in 0...sp_zeilen){
			for (i in 0...sp_spalten){
				if (a[j][i]=="temp"){
					a[j][i]="s6";
				}
			}
		}
		
		frame--;
		anim.maxabweichung=frame;
	
	}



	function loeschen(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;

		var frame=1;

		f[y][x]=-1;

		function ersetzen(von,zu,fr){
			var ersetzt=false;
			for (j in 0...sp_zeilen){
				for (i in 0...sp_spalten){
					if (a[j][i]==von && f[j][i]==-1){
						a[j][i]=zu;
						f[j][i]=fr;
						ersetzt=true;
					}
				}
			}
			return ersetzt;
		}

		if (a[y][x]!=null){
			//osten
			if (x<sp_spalten-1){
				var vn = a[y][x+1];
					a[y][x+1]=null;
					f[y][x+1]=frame;
					frame++;
					
				if (vn!=null){
					if (ersetzen(vn,null,frame)){
						frame++;
					}
				}
			}
		}
		

		if (a[y][x]!=null){
			//suden
			if (y<sp_zeilen-1){
				var vn = a[y+1][x];
					a[y+1][x]=null;
					f[y+1][x]=frame;
					frame++;
					
				if (vn!=null){
					if (ersetzen(vn,null,frame)){
						frame++;
					}
				}
			}
		}		
		
		if (a[y][x]!=null){
			//westen
			if (x>0){
				var vn = a[y][x-1];
					a[y][x-1]=null;
					f[y][x-1]=frame;
					frame++;
					
				if (vn!=null){
					if (ersetzen(vn,null,frame)){
						frame++;
					}
				}
			}
		}




		if (a[y][x]!=null){
			//norden
			if (y>0){
				var vn = a[y-1][x];
					a[y-1][x]=null;
					f[y-1][x]=frame;
					frame++;
					
				if (vn!=null){
					if (ersetzen(vn,null,frame)){
						frame++;
					}
				}
			}
		}







		frame--;
		anim.maxabweichung=frame;
	
	}

	function behaaren(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;
		

		function nichtfellob(px,py){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return false;
			}
			if (a[py][px]==null){
				return false;
			}
			return a[py][px]!="s2"; 
		}

		a[y][x]="s2";
		f[y][x]=0;
		var aenders=true;
		var frame=1;
		while (aenders){
			aenders=false;

			for (j in 0...sp_zeilen){
				for (i in 0...sp_spalten){
					var n = a[j][i];
					if (n==null || n=="s2"){
						continue;
					}
				
					function fellBei(px,py):Bool{
						if (px<0||py<0||px>=sp_spalten||py>=sp_zeilen){
							return false;
						}
						var val = a[py][px];
						if (val =="s2"){
							return true;
						}
						return false;
					}

					function aktuellesFellBei(px,py):Bool{
						if (px<0||py<0||px>=sp_spalten||py>=sp_zeilen){
							return false;
						}
						var val = a[py][px];
						if (val =="s2" && f[py][px]==(frame-1)){
							return true;
						}
						return false;
					}

					function versuchBehaaren(px,py){

						if (px<0||py<0||px>=sp_spalten||py>=sp_zeilen){
							return ;
						}

						if (a[py][px]!=null){
							return;
						}

						if (
						aktuellesFellBei(px-1,py-1)||
						aktuellesFellBei(px-1,py+0)||
						aktuellesFellBei(px-1,py+1)||
						aktuellesFellBei(px+0,py-1)||
						aktuellesFellBei(px+0,py+1)||
						aktuellesFellBei(px+1,py-1)||
						aktuellesFellBei(px+1,py+0)||
						aktuellesFellBei(px+1,py+1) 
						){
							if (
								(nichtfellob(px+1,py)  ) ||
								(nichtfellob(px,py+1)  ) ||
								(nichtfellob(px,py-1)  ) ||
								(nichtfellob(px-1,py)  ) 
							){
								a[py][px]="s2";
								f[py][px]=frame;
								aenders=true;
							}
						}
					}
					
					if (
						fellBei(i-1,j-1)||
						fellBei(i-1,j+0)||
						fellBei(i-1,j+1)||
						fellBei(i+0,j-1)||
						fellBei(i+0,j+1)||
						fellBei(i+1,j-1)||
						fellBei(i+1,j+0)||
						fellBei(i+1,j+1)
					) {
						versuchBehaaren(i-1,j-1);
						versuchBehaaren(i-1,j-0);
						versuchBehaaren(i-1,j+1);
						versuchBehaaren(i-0,j-1);
						versuchBehaaren(i-0,j+1);
						versuchBehaaren(i+1,j-1);
						versuchBehaaren(i+1,j-0);
						versuchBehaaren(i+1,j+1);
					}
				}
			}
			frame++;
		}

		
		frame--;
		anim.maxabweichung=frame;
	
	}

	function spiralen(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
		var x= hoverziel_x;
		var y = hoverziel_y;
		var frame=0;
		y--;

		//heroben
		while (y>=0){
			if (anim.nach_brett[y][x]!=null){
				break;
			}
			anim.nach_brett[y][x]="s12";
			anim.abweichung[y][x]=frame;
			frame++;
			y--;
		}
		y++;

		//rechts
		x++;
		while (x<sp_spalten){
			if (anim.nach_brett[y][x]!=null){
				break;
			}

			anim.nach_brett[y][x]="s12";
			anim.abweichung[y][x]=frame;
			frame++;
			x++;
		}
		x--;
		
		y++;

		//herunten
		while (y<sp_zeilen){
			if (anim.nach_brett[y][x]!=null){
				break;
			}
			anim.nach_brett[y][x]="s12";
			anim.abweichung[y][x]=frame;
			frame++;
			y++;
		}
		y--;


		//links
		x--;
		while (x>=0){
			if (anim.nach_brett[y][x]!=null){
				break;
			}

			anim.nach_brett[y][x]="s12";
			anim.abweichung[y][x]=frame;
			frame++;
			x--;
		}
		x++;

		frame--;
		anim.maxabweichung=frame;
	}


	function schraegspiegeln(anim:AnimationFrame,x:Int,y:Int){
		var a = anim.nach_brett;
		var f = anim.abweichung;

		function setf(px,py,v){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return;
			}
			f[py][px]=v;
		}


		function get_vorbrett(px,py){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return null;
			}
			return anim.vor_brett[py][px];
		}

		function getf(px,py,def){
			if (px<0||px>=sp_spalten ||py<0||py>=sp_zeilen){
				return def;
			}
			return f[py][px];
		}


		var schritte = sp_spalten+sp_zeilen;
		for (i in 0...schritte){
			var l_x=x+i;
			var l_y=y-i;
			
			var u_x=x-i;
			var u_y=y+i;
			
			setf(u_x,u_y,0);
			setf(l_x,l_y,0);			
		}

		var frames=0;
		
		var geaendert=true;
		while(geaendert){
			geaendert=false;
			
			for (j in 0...sp_zeilen){
				for (i in 0...sp_spalten){
					var deltax = i-x;
					var deltay = j-y;
					if (deltax==0&&deltay==0){
						continue;
					}
					
					var i2 = x-deltay;
					var j2 = y-deltax;
					a[j][i]=get_vorbrett(i2,j2);

					if (f[j][i]>=0){
						continue;
					}
					var v1 = getf(i-1,j,-1);
					var v2 = getf(i,j-1,-1);
					var v3 = getf(i+1,j,-1);
					var v4 = getf(i,j+1,-1);
					var m = v1;
					if (v2>m){
						m=v2;
					}
					if (v3>m){
						m=v3;
					}
					if (v4>m){
						m=v4;
					}
					if (m>=0){
						m++;
						f[j][i]=m;
						geaendert=true;
						if (m>frames){
							frames=m;
						}
					}					
				}
			}

		}
		anim.maxabweichung=frames;
	}
	function spiegeln_hinunten(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
	
	
		var max_frame=0;

		for (j in 0...sp_zeilen){
			var j_von=hoverziel_y-j;
			var j_zu=hoverziel_y+j;
			if (j_von>=0 && j_von<sp_zeilen){
				for (x in 0...sp_spalten){
					anim.abweichung[j_von][x]=j;
					if (j>max_frame){
						max_frame=j;
					}
				}
			}
			if (j_zu>=0 && j_zu<sp_zeilen){
				for (x in 0...sp_spalten){
					if (j!=0){
						anim.nach_brett[j_zu][x]=null;
					}
					anim.abweichung[j_zu][x]=j;
					if (j>max_frame){
						max_frame=j;
					}
				}
			}

			if (j_von>=0 && j_von<sp_zeilen && j_zu>=0 && j_zu<sp_zeilen){
				for (x in 0...sp_spalten){
					anim.nach_brett[j_zu][x]=anim.nach_brett[j_von][x];
				}
			}
		}
		
		anim.maxabweichung=max_frame;

	}

	function spiegeln_hinoben(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
	
	
		var max_frame=0;

		for (j in 0...sp_zeilen){
			var j_von=hoverziel_y+j;
			var j_zu=hoverziel_y-j;
			if (j_von>=0 && j_von<sp_zeilen){
				for (x in 0...sp_spalten){
					anim.abweichung[j_von][x]=j;
					if (j>max_frame){
						max_frame=j;
					}
				}
			}
			if (j_zu>=0 && j_zu<sp_zeilen){
				for (x in 0...sp_spalten){
					if (j!=0){
						anim.nach_brett[j_zu][x]=null;
					}
					anim.abweichung[j_zu][x]=j;
					if (j>max_frame){
						max_frame=j;
					}
				}
			}

			if (j_von>=0 && j_von<sp_zeilen && j_zu>=0 && j_zu<sp_zeilen){
				for (x in 0...sp_spalten){
					anim.nach_brett[j_zu][x]=anim.nach_brett[j_von][x];
				}
			}
		}
		
		anim.maxabweichung=max_frame;
	}

	function versuchfallenzulassen(x:Int,y:Int){
		var erlauben=false;
		
		for (j in 0...sp_zeilen){
			for (i in 0...sp_spalten){
				if (szs_brett[j][i]=="s9" && !(x==i&&y==j)){
					if (j==sp_zeilen-1){
						erlauben=true;
						break;
					}
					if (szs_brett[j+1][i]==null){
						erlauben=true;
						break;
					}
				}
			}
		}
		if (erlauben==false){
			return;
		}

		var startframe = new AnimationFrame();
		startframe.vor_brett = Copy.copy(szs_brett);
		startframe.nach_brett = Copy.copy(szs_brett);
		startframe.abweichung = leererAbweichungsgitter();
		var animation = startframe;
		animationen.push(animation);


		var startframe2 = new AnimationFrame();
		startframe2.vor_brett = Copy.copy(szs_brett);
		startframe2.nach_brett = Copy.copy(szs_brett);
		startframe2.abweichung = leererAbweichungsgitter();
		var animation2 = startframe2;
		animationen.push(animation2);

		{
			var j = sp_zeilen-1;
			while(j>=0){
				for (i in 0...sp_spalten){
					if (startframe.nach_brett[j][i]=="s9" && !(x==i&&y==j)){
						if (j==sp_zeilen-1){
							animation2.nach_brett[j][i]=null;
							animation.abweichung[j][i]=0;
							animation2.abweichung[j][i]=0;
						} else {
							if (animation2.nach_brett[j+1][i]==null) {
								animation2.nach_brett[j][i]=null;
								animation2.nach_brett[j+1][i]="s9";
								animation.abweichung[j][i]=0;
								animation2.abweichung[j+1][i]=0;
							}
						}
					}
				}
				j--;
			}	
		}

		animation.maxabweichung=0;
		animation2.maxabweichung=0;


	}

	function versuchaufzuwachsen(x:Int,y:Int){
		
		var targets=[];

		for (j in 0...sp_zeilen){
			for (i in 0...sp_spalten){
				if (szs_brett[j][i]=="s20" && !(x==i&&y==j)){
					var k = j-1;
					while(k>=0){
						if (szs_brett[k][i]==null){
							targets.push([i,k]);
							break;
						}
						if (szs_brett[k][i]!="s21"){
							break;
						}
						k--;
					}
				}
			}
		}
		if (targets.length==0){
			return;
		}

		var startframe = new AnimationFrame();
		startframe.vor_brett = Copy.copy(szs_brett);
		startframe.nach_brett = Copy.copy(szs_brett);
		startframe.abweichung = leererAbweichungsgitter();
		var animation = startframe;
		animationen.push(animation);


		
		for (p in targets){
			var x = p[0];
			var y = p[1];
			animation.nach_brett[y][x]="s21";
			animation.abweichung[y][x]=1;
		}

		animation.maxabweichung=1;


	}

	function tuePlatzierung(hoverziel_x:Int,hoverziel_y:Int,z_name:String,nachkram:Bool){	
		var startframe = new AnimationFrame();
		startframe.vor_brett = Copy.copy(szs_brett);

		szs_brett[hoverziel_y][hoverziel_x]=z_name;
		startframe.nach_brett = Copy.copy(szs_brett);
		startframe.abweichung = leererAbweichungsgitter();
		startframe.abweichung[hoverziel_y][hoverziel_x]=0;
		startframe.maxabweichung=0;
		var animation = startframe;
		animationen.push(animation);

		switch(z_name){
			case "s1":
				loeschen(animation,hoverziel_x,hoverziel_y);
			case "s2":
				behaaren(animation,hoverziel_x,hoverziel_y);			

			case "s3":
				spalte_entleeren(animation,hoverziel_x,hoverziel_y);			
			case "s4":
				zeile_entleeren(animation,hoverziel_x,hoverziel_y);
			
			case "s5":
				spazieren(animation,hoverziel_x,hoverziel_y);
			case "s6":
				fuellen(animation,hoverziel_x,hoverziel_y);
			case "s7":
				spiegelkopien(animation,hoverziel_x,hoverziel_y);	
			
			case "s8":
				ziehen(animation,hoverziel_x,hoverziel_y);
			case "s9":
			
			case "s10":
			
			case "s11":
			
			case "s12":
				spiralen(animation,hoverziel_x,hoverziel_y);	
			
			case "s13":
				schieben(animation,hoverziel_x,hoverziel_y);
			
			case "s14":
				drehen(animation,hoverziel_x,hoverziel_y);
			case "s15":
				schraegspiegeln(animation,hoverziel_x,hoverziel_y);	
			case "s16":
				spiegeln_hinunten(animation,hoverziel_x,hoverziel_y);		
			case "s17":
				spiegeln_hinoben(animation,hoverziel_x,hoverziel_y);
			case "s18":
				wiederholen(animation,hoverziel_x,hoverziel_y);
			case "s19":
				bomben(animation,hoverziel_x,hoverziel_y);
			
			case "s20":

			
		}


		szs_brett = animationen[animationen.length-1].nach_brett;

		if (nachkram){
			var tx = hoverziel_x;
			var ty = hoverziel_y;
			var tb = animationen[animationen.length-1].nach_brett;
			if (z_name=="s18"){
				tx=-1;
				ty=-1;
			}
			versuchfallenzulassen(tx,ty);
			szs_brett = animationen[animationen.length-1].nach_brett;
			versuchaufzuwachsen(tx,ty);

			szs_brett = animationen[animationen.length-1].nach_brett;

			zustandSpeichern();
			checkSolve(true);
		}

	}

	public static var farbe_desktop = 0x7869c4;
	public static var farbe_menutext = 0x9f9f9f;
	function init(){
		// Text.font = "dos";
		// Sound.play("t2");
		//Music.play("music",0,true);
		Gfx.resizescreen(392, 235,true);
		SpriteManager.enable();
		Particle.enable();
		Text.font="nokia";
		// Gfx.clearcolor=Col.RED;// desktop_farbe;
		// Gfx.loadtiles("dice_highlighted",16,16);
		setup();
	}	


// var i_contents = [
// 		10,11,
// 		13,8,
// 		3,4,
// 		9,20,
// 		16,17,
// 		12,5,
// 		6,2,
// 		14,15,
// 		1,7,
// 		19,18
// 	];


		var invfolge = [
			12,1,7,3,
			14,6,11,4,
			18,5,13,10,
			2,8,20,9,
			15,17,16,19
		];


	function neuesBlatt(){	

		animationen = new Array<AnimationFrame>();
		zieh_modus=false;
		szs_inventory = new Array<Array<String>>();
		for (j in 0...i_zeilen){
			var zeile = new Array<String>();
			for (i in 0...i_spalten){
				var index = i+i_spalten*j;
				if (aktuellesZiel==null || aktuellesZiel.werkzeuge[index]==true)
				{
					zeile.push("s"+invfolge[index]);
				} else {
					zeile.push(null);
				}
			}
			szs_inventory.push(zeile);

		} 


		szs_brett = new Array<Array<String>>();
		for (j in 0...sp_zeilen){
			var zeile = new Array<String>();
			for (i in 0...sp_spalten){
				var index = i+sp_spalten*j+1 ;
				zeile.push(null);
			}
			szs_brett.push(zeile);
		} 
		zustandSpeichern();
	}

	var undoStack:Array<Array<LevelZustand>>;
	var undoPos:Array<Int>;

	function zustandSpeichern(){
		var curUndoPos = undoPos[aktuellesZielIdx];
		var curUndoStack = undoStack[aktuellesZielIdx];
		curUndoStack.splice(curUndoPos+1,curUndoStack.length);

		var lzs = new LevelZustand();
		lzs.i=Copy.copy(szs_inventory);
		lzs.sp=Copy.copy(szs_brett);
		lzs.hash=Json.stringify([szs_inventory,szs_brett]);

		var dieser_undoStack = undoStack[aktuellesZielIdx];
		if (dieser_undoStack.length>0){
			if (dieser_undoStack[dieser_undoStack.length-1].hash==lzs.hash){
				return;//keine duplikaten
			}
		}
		dieser_undoStack.push(lzs);
		undoPos[aktuellesZielIdx]++;
	}
	
	function tueUndo(){
		animationen.splice(0,animationen.length);	
		animPos=0;		
		var curhash = Json.stringify([szs_inventory,szs_brett]);
		var i = undoPos[aktuellesZielIdx];
		while (i>=0){
			var zs = undoStack[aktuellesZielIdx][i];
			if (curhash!=zs.hash){
				szs_inventory=Copy.copy(zs.i);
				szs_brett=Copy.copy(zs.sp);
				checkSolve(false);
				do_playSound(0);
				undoPos[aktuellesZielIdx]=i;
				forcerender=true;
				return;
			} else {
				if (i>0){
					// undoStack[aktuellesZielIdx].splice(i,1);
				}
			}
			i--;
		}
	}

function tueRedo(){
		animationen.splice(0,animationen.length);	
		animPos=0;		
		var curhash = Json.stringify([szs_inventory,szs_brett]);
		var i = undoPos[aktuellesZielIdx];
		while (i<undoStack[aktuellesZielIdx].length){
			var zs = undoStack[aktuellesZielIdx][i];
			if (curhash!=zs.hash){
				szs_inventory=Copy.copy(zs.i);
				szs_brett=Copy.copy(zs.sp);
				checkSolve(false);
				do_playSound(0);
				undoPos[aktuellesZielIdx]=i;
				forcerender=true;
				return;
			} else {
				if (i>0){
					// undoStack[aktuellesZielIdx].splice(i,1);
				}
			}
			i++;
		}
	}

	private var alphabet =".abcdefghijklmnopqrstuvwxyz";
	function drueckBrett(){
		var z = new Array<Array<String>>();
		for (j in editor_tl_y...editor_br_y){
			var r = new Array<String>();
			for (i in editor_tl_x...editor_br_x){
				r.push(szs_brett[j][i]);
			}
			z.push(r);
		}
		var wz :Array<Bool>= Copy.copy(aktuellesZiel.werkzeuge);

		var new_z  = new Ziel(z,wz);
    	    
		var serializer = new Serializer();
		serializer.serialize(new_z);
		
		aktuellesZiel=new_z;

		var s = serializer.toString();
		ziele[aktuellesZielIdx]=[""+version,s];

		#if html5 
			Browser.alert('"'+s+'",');
		#end

		trace(s);
	}


	function versperre(i:Int,j:Int){
		aktuellesZiel.werkzeuge[i+i_spalten*j]=!aktuellesZiel.werkzeuge[i+i_spalten*j];
		if (aktuellesZiel.werkzeuge[i+i_spalten*j]==false){
			szs_inventory[j][i]=null;
		} else {
			szs_inventory[j][i]="s"+(i+i_spalten*j+1);
		}
	}

	var forcerender:Bool=true;
	
	var zeigabout:Bool=false;

	function update() {	


		var keyrepeat=Math.floor(Core.fps/5);

		if (Input.justpressed(Key.A)){
			editmodus=!editmodus;
			forcerender=true;
		}
		if (
			Mouse.deltax==0 &&
			Mouse.deltay==0 &&
			!Mouse.leftclick() && 
			!Mouse.leftreleased() &&
			!Mouse.leftheld() &&
			!Input.justpressed(Key.P) &&
			!Input.justpressed(Key.N) &&
			!Input.justpressed(Key.R) &&
			!Input.delaypressed(Key.Y,keyrepeat) &&
			!Input.justpressed(Key.M) &&
			!Input.delaypressed(Key.Z,keyrepeat) &&
			!Input.delaypressed(Key.U,keyrepeat) &&
			!Input.justpressed(Key.E) &&
			!Input.justpressed(Key.Q) &&
			!Input.justpressed(Key.W) &&
			!Input.delaypressed(Key.LEFT,keyrepeat) &&
			!Input.delaypressed(Key.RIGHT,keyrepeat) &&
			!Particle.active() &&
			animationen.length==0 &&
			forcerender==false
			)
		{
				return;
		}

		if (zeigabout){
			Text.wordwrap=277;

			Gfx.drawimage(0,0,"aboutscreen");
			
			Text.display(57,25,Globals.S("Über Gestalt_BS","About Gestalt_OS","Sobre Gestalt_OS","Sûr Gestalt_OS"),farbe_menutext);

			Text.display(153,44,Globals.S("Gestaltaufbau","Gestalt Manufacturing","Fabricación Gestalt","Fabrication Gestalt"),0x20116d);
			Text.display(153,55,Globals.S("GmbH (R)","Corporation (R)","Sociedad (R)","Société (R)"),0x20116d);
			
			Text.display(153,73,Globals.S("Gestalt_BS 3.14 (\"Beton\")","Gestalt_OS 3.14 (\"Beton\")",'Gestalt_OS 3.14 ("Beton")','Gestalt_OS 3.14 ("Beton")'),0x20116d);
			Text.display(153,90,Globals.S("(R) GAB GmbH 2019","Copyright(C) 2019 GMC",'Copyright(C) 2019 SFC',"Droit d'auteur (C) 2019 SFC"),0x20116d);

			var nameListe = "Daniel Frier - Stephen Saver - David Kilford - Dani Soria - Adrian Toncean - Alvaro Salvagno - Ethan Clark - Blake Regehr - Happy Snake - Joel Gahr - Alexander Turner - Tatsunami - Matt Rix - Bigaston - Lajos Kis - Lorxus - Fachewachewa - Marcos Donnantuoni - That Scar - Llewelyn Griffiths - @capnsquishy - Alexander Martin - Guilherme Töws - Alex Fink - Christian Zachau - @Ilija - Celeste Brault - Cédric Coulon - Lukas Koudelka - George Kurelic - Konstantin Dediukhin";

			Text.font = "pixel";
			Text.display(56,113,
			Globals.S("Dank für Testing und Feedback zu sagen zu : "+nameListe+".
			
			Level Design: Lucas Le Slo ( http://le-slo.itch.io ) - Stephen Lavelle.
			
			Der Rest: Stephen Lavelle",
			"Thanks for testing and feedback to : "+nameListe+".
			
			Level Design: Lucas Le Slo ( http://le-slo.itch.io ) - Stephen Lavelle.
			
			The Rest: Stephen Lavelle ( http://www.increpare.com ).",
			"Gracias por probar y comentar a: "+nameListe+"
			
			Diseño de niveles: Lucas Le Slo ( http://le-slo.itch.io ) - Stephen Lavelle.

			Traducciones al Español y Francés: Lucas Le Slo

			El resto:  Stephen Lavelle ( http://www.increpare.com ).
			",
			"Merci pour tester et donner du feedback à: "+nameListe+"
			
			Conception de niveaux:  Lucas Le Slo ( http://le-slo.itch.io ) - Stephen Lavelle.

			Traductions française et espagnole: Lucas Le Slo

			Le reste: Stephen Lavelle ( http://www.increpare.com ).
			"			
			),0x20116d
			);
			Text.wordwrap=0;			
			Text.font="nokia";

			if (
				IMGUI.presstextbutton(
					"ueber_ok",
					"btn_solve_bg_up",
					"btn_solve_bg_down",
					Globals.S("OK","OK","OK","OK"),
					0x20116d,
					279,193
					))
			{
				zeigabout=false;
				Core.fullscreenbutton(isFullscreenButtonPressed,326,209,Gfx.imagewidth("taste_t_bg_up"),Gfx.imageheight("taste_t_bg_up"));
				forcerender=true;
			}
	
			return;
		}

		forcerender=false;

		if (Input.justpressed(Key.P)){
			drueckBrett();
		}

		if (Mouse.leftclick()){
			animationen.splice(0,animationen.length);	
			animPos=0;		
		}
		if (animationen.length>0){
			var animation=animationen[0];
			animPos++;
			if (animPos>animFrameDauer*(animation.maxabweichung+1)){
				animationen.shift();		
				animPos=0;		
			}
		}

		
		Gfx.drawimage(0,0,"bg");
	
		// Gfx.drawimage(7,7,"taste_t_bg_up");
		if (IMGUI.pressbutton(
				"neu",
				"taste_t_bg_up",
				"taste_t_bg_down",
				"icon_neu",
				286,209,
				Globals.S("Blatt leeren (N)","Clear page (N)","Borrar página (N)",'Effacer page (N)')
				)  
				|| Input.justpressed(Key.N)
				|| Input.justpressed(Key.R)
				)
		{
			neuesBlatt();
			forcerender=true;
		}

		if (undoPos[aktuellesZielIdx]>0){
			if (IMGUI.pressbutton(
					"rückgängig",
					"taste_t_bg_up",
					"taste_t_bg_down",
					"icon_undo",
					306,209,
					Globals.S("Rückgängig (Z)","Undo (Z)",'Deshacer (Z)','Défaire (Z)')
					)
					|| Input.delaypressed(Key.Z,keyrepeat)
					|| Input.delaypressed(Key.U,keyrepeat)
					)
			{
					tueUndo();
			}
		} else {
			Gfx.drawimage(306,209,"keineundosmehr");
		}


		if ( (undoPos[aktuellesZielIdx]+1)<undoStack[aktuellesZielIdx].length){

			if (IMGUI.pressbutton(
					"wiederholen",
					"taste_t_bg_up",
					"taste_t_bg_down",
					"icon_wiederholen",
					326,209,
					Globals.S("Wiederholen (Y)","Undo (Y)",'Rehacer (Y)','Rétablir (Y)')
					)
					|| Input.delaypressed(Key.Y,keyrepeat)
					)
			{
					tueRedo();
			}
		} else {
			Gfx.drawimage(326,209,"keinredosmehr");
		}

		var neu_spr:Int = IMGUI.togglebutton_multi(
			"sprache",
			"taste_t_bg_up",
			"taste_t_bg_down",
			["icon_flagge_en",
			"icon_flagge_de",
			"icon_flagge_es",
			"icon_flagge_fr"],
			346,209,
			Globals.state.sprache,
			[
			Globals.S("Sprache: Englisch","Language: English",'Idioma: Inglés','Langue: Anglais'),
			Globals.S("Sprache: Deutsch","Language: German",'Idioma: Alemán','Langue: Allemand'),
			Globals.S('Sprache: Spanisch','Language: Spanish','Idioma: Español','Langue: Spagnol'),
			Globals.S('Sprache: Französisch','Language: French','Idioma: Francés','Langue: Français')]
			);

		if (neu_spr!=Globals.state.sprache){
				Globals.state.sprache=neu_spr;
				IMGUI.tooltipstr=null;
				forcerender=true;
			Save.savevalue("mwbsprache_v2",Globals.state.sprache);
		}

		if (IMGUI.pressbutton(
			"hilfe",
			"taste_t_bg_up",
			"taste_t_bg_down",
			"icon_hilfe",
			366,209,
			Globals.S("Über diese Anwendung","About this app","Sobre esta aplicación","Sûr cette aplication")
			)){
				zeigabout=true;
				Core.fullscreenbutton(null,0,0,0,0);
				forcerender=true;
			}

		Text.display(9,8,Globals.S("Werkzeuge","Tools","Herramientas","Outils"),farbe_menutext);


		var lebende = Lambda.count(Globals.state.solved, (w)->w==0);
		var titeltext="";
		if (lebende>1){
			titeltext = Globals.S("Werkbank","Workbench","Mesa de trabajo","Table de travail");// + " (" + lebende + Globals.S(" leben noch"," still live")+")." ;
		} else {
			titeltext = Globals.S("Werkbank","Workbench","Mesa de trabajo","Table de travail");// + " (" + lebende + Globals.S(" lebt noch"," still lives")+")." ;
		}
		Text.display(91,8,titeltext,farbe_menutext);

		Text.display(287,8,Globals.S(
				"Ziel ("+(aktuellesZielIdx+1) +" von "+ziele.length+")",
				"Goal ("+(aktuellesZielIdx+1) +" of "+ziele.length+")",
				"Objetivo ("+(aktuellesZielIdx+1) +" de "+ziele.length+")",
				"Cible ("+(aktuellesZielIdx+1) +" de "+ziele.length+")"
				),farbe_menutext);

		if (aktuellesZielIdx>0){
			if(IMGUI.pressbutton("menü_l","taste_t_bg_up","taste_t_bg_down","icon_sm_l",286,182)||Input.delaypressed(Key.LEFT,keyrepeat)){
				LoadLevel(aktuellesZielIdx-1);
			}
		} else {
			Gfx.drawimage(286,182,"taste_t_bg_up");
			Gfx.drawimage(286,182,"icon_sm_l_deaktiviert");

		}


		if (geloest[aktuellesZielIdx]==ziele[aktuellesZielIdx][0]){
			IMGUI.presstextbutton_disabled(
						"menü_l",
						"btn_solve_bg_down_done",
						"btn_solve_bg_down_done",
						Globals.S("Gelöst","Solved","Resuelto","Résolu"),
						0x505050,
						306,182
						);
		} else if (cansolve){
			if(IMGUI.presstextbutton("loesentaste","btn_solve_bg_up","btn_solve_bg_down",Globals.S("Lösen","Solve","Resolver","Résoudre"),0x20116d,306,182)){
				geloest[aktuellesZielIdx]=ziele[aktuellesZielIdx][0];
				Save.savevalue("level"+version+"-"+aktuellesZielIdx,ziele[aktuellesZielIdx][0]);
				forcerender=true;
			}
		} else {
					IMGUI.presstextbutton_disabled(
						"menü_l",
						"btn_solve_bg_up",
						"btn_solve_bg_down",
						Globals.S("Lösen","Solve","Resolver","Résoudre"),
						0x505050,
						306,182
						);
		}
		
		if (aktuellesZielIdx+1<ziele.length){
			if(IMGUI.pressbutton("menü_r","taste_t_bg_up","taste_t_bg_down","icon_sm_r",366,182)||Input.delaypressed(Key.RIGHT,keyrepeat)){
				LoadLevel(aktuellesZielIdx+1);
			}
		} else {
			Gfx.drawimage(366,182,"taste_t_bg_up");
			Gfx.drawimage(366,182,"icon_sm_r_deaktiviert");
		}

		// Gfx.drawimage(Mouse.x-3,Mouse.y-3,"cursor_finger");


		for (j in 0...i_zeilen){
			for (i in 0...i_spalten){

				var ix = 8+19*i;
				var iy = 21+19*j;
				

				var index = i+i_spalten*j;
				
				if (editmodus){
					if (IMGUI.mouseover(
							"schatten/s"+invfolge[index],
							ix,
							iy) &&
						Input.justpressed(Key.E) )
					{
						versperre(i,j);
					}
				}

				var inhalt = szs_inventory[j][i];
				

				if (inhalt!=null){
					if (IMGUI.clickableimage(
							"icons/"+inhalt,
							ix,
							iy)){
						zieh_name = szs_inventory[j][i];
						szs_inventory[j][i] = null;
						zieh_modus=true;

						do_playSound(3);
						zieh_offset_x=(ix)-Mouse.x;
						zieh_offset_y=(iy)-Mouse.y;
						zieh_quelle_i=i;
						zieh_quelle_j=j;
					}
				} else {
					Gfx.drawimage(ix,iy,"schatten/s"+invfolge[index]);
					if (aktuellesZiel.werkzeuge[index]==false){
						Gfx.drawimage(ix,iy,"versperrt");
					}
				}
				
			}
		}


		var zielb_x=284;
		var zielb_y=19;

		var zielb_w=103;
		var zielb_h=163;
		
		//ziel zeigen
		if (aktuellesZielIdx>=48){
			var image_s = aktuellesZielIdx==48 ? "leererlevel" : "letzterlevel";

			var ziel_darstellung_w=Gfx.imagewidth(image_s);
			var ziel_darstellung_h=Gfx.imageheight(image_s);

			var ziel_x=zielb_x+zielb_w/2-ziel_darstellung_w/2;
			var ziel_y=zielb_y+zielb_h/2-ziel_darstellung_h/2;
			Gfx.drawimage(ziel_x,ziel_y,image_s);
		} else {
			var alevel = aktuellesZiel;
			var z_raster = alevel.ziel;
			var z_w = z_raster[0].length;
			var z_h = z_raster.length;


			var ziel_darstellung_w=17*z_w+1;
			var ziel_darstellung_h=17*z_h+1;

			var ziel_x=zielb_x+zielb_w/2-ziel_darstellung_w/2;
			var ziel_y=zielb_y+zielb_h/2-ziel_darstellung_h/2;

			for (i in 0...z_w){
				for (j in 0...z_h){
					
					Gfx.drawimage(ziel_x+17*i,ziel_y+17*j,"zielgitterkiste");
					var inhalt = z_raster[j][i];
					if (inhalt!=null){
						Gfx.drawimage(ziel_x+17*i+1,ziel_y+17*j+1,"icons/"+inhalt);
					}
				}
			}

		}

		var brett_vor = szs_brett;
		var brett_nach = szs_brett;
		var abweichungsbrett = null;
		var frame = Math.floor(animPos/animFrameDauer);
		if (animationen.length>0){
			var animation=animationen[0];
			brett_vor = animation.vor_brett;
			brett_nach = animation.nach_brett;
			abweichungsbrett = animation.abweichung;
		}

		for (j in 0...sp_zeilen){
			for (i in 0...sp_spalten){
				var inhalt = brett_vor[j][i];
				var abw=-1;
				if (animationen.length>0){
					abw = abweichungsbrett[j][i];
					if (abw<=frame){
						inhalt=brett_nach[j][i];
					}
				}
				if (inhalt!=null){
					Gfx.fillbox(90+19*i,21+19*j,16,16,0x6a6a6a);
					Gfx.drawimage(90+19*i,21+19*j,"icons/"+inhalt);
				}
				if (abw==frame){
					Gfx.drawimage(90+19*i,21+19*j,"cursor_aktiv");
				}
			}
		}
		
		if (editmodus){
			var input:Int=0;
			if (Input.justpressed(Key.Q)){
				input=1;
			}
			if (Input.justpressed(Key.W)){
				input=2;
			}
			if (input>0){
				var hoverziel_x=-1;
				var hoverziel_y=-1;

				var geltendes_hoverziel=false;

				var mx=Mouse.x;
				var my=Mouse.y;

				var ox = mx-89;
				var oy = my-20;
				var ox_d = ox % 19;
				var oy_d = oy % 19;

				var nope:Bool=false;
				if ((ox_d==18||oy_d==18) && (letztes_hoverziel_x>=0)){
					hoverziel_x=letztes_hoverziel_x;
					hoverziel_y=letztes_hoverziel_y;
					if (ox_d<18){
						hoverziel_x=Math.floor(ox/19);
					} else {
						hoverziel_y=Math.floor(oy/19);
					}
				} else if (ox_d<18 && oy_d<18){
					hoverziel_x=Math.floor(ox/19);
					hoverziel_y=Math.floor(oy/19);					
				}

				if (hoverziel_x>=0 && hoverziel_x<sp_spalten && hoverziel_y>=0 && hoverziel_y<sp_zeilen){
					geltendes_hoverziel=true;
					letztes_hoverziel_x=hoverziel_x;
					letztes_hoverziel_y=hoverziel_y;
				} else {
					letztes_hoverziel_x=-1;
					letztes_hoverziel_y=-1;
				}
				
				if (geltendes_hoverziel){
					if (input==1){
						editor_tl_x=hoverziel_x;
						editor_tl_y=hoverziel_y;
					} else {
						editor_br_x=hoverziel_x+1;
						editor_br_y=hoverziel_y+1;
					}
					if (editor_tl_x>editor_br_x){
						var t = editor_tl_x;
						editor_tl_x=editor_br_x;
						editor_br_x=t;
					}
					if (editor_br_y<editor_tl_y){
						var t = editor_br_y;
						editor_br_y=editor_tl_y;
						editor_tl_y=t;
					}
				}
			}
			
			if (editor_tl_x>=0){
				var b_w=editor_br_x-editor_tl_x;
				var b_h=editor_br_y-editor_tl_y;
				b_w = b_w*19+1;
				b_h = b_h*19+1;
				Gfx.drawbox(89+editor_tl_x*19-1,20+editor_tl_y*19-1,b_w,b_h,Col.RED);
			}
		}
		
		if (zieh_modus==true){

			var hoverziel_x=-1;
			var hoverziel_y=-1;
			var geltendes_hoverziel=false;

			var mx=Mouse.x;
			var my=Mouse.y;

			var ox = mx-89;
			var oy = my-20;
			var ox_d = ox % 19;
			var oy_d = oy % 19;

			var nope:Bool=false;

			if ((ox_d==18||oy_d==18) && (letztes_hoverziel_x>=0)){
				hoverziel_x=letztes_hoverziel_x;
				hoverziel_y=letztes_hoverziel_y;
				if (ox_d<18){
					hoverziel_x=Math.floor(ox/19);
				} else {
					hoverziel_y=Math.floor(oy/19);
				}
			} else if (ox_d<18 && oy_d<18){
				hoverziel_x=Math.floor(ox/19);
				hoverziel_y=Math.floor(oy/19);					
			}

			if (hoverziel_x>=0 && hoverziel_x<sp_spalten && hoverziel_y>=0 && hoverziel_y<sp_zeilen){
				geltendes_hoverziel=true;
				letztes_hoverziel_x=hoverziel_x;
				letztes_hoverziel_y=hoverziel_y;
			} else {
				letztes_hoverziel_x=-1;
				letztes_hoverziel_y=-1;
			}

			
			if (geltendes_hoverziel){
				if (szs_brett[hoverziel_y][hoverziel_x]==null){
					Gfx.drawimage(90+19*hoverziel_x,21+19*hoverziel_y,"zelle_hervorhebung");
				} else {
					geltendes_hoverziel=false;
					nope=true;
				}
			}
			
			var im_x=Mouse.x+zieh_offset_x;
			var im_y=Mouse.y+zieh_offset_y;
			Gfx.drawimage(im_x,im_y,"icons/"+zieh_name);
			// if (nope){
			// 	Gfx.drawimage(im_x,im_y,"keine_platzierung_erlaubt");
			// }
			if (Mouse.leftreleased()){
				zieh_modus=false;


				if (geltendes_hoverziel==false){
					szs_inventory[zieh_quelle_j][zieh_quelle_i]=zieh_name;
				} else {
					tuePlatzierung(hoverziel_x,hoverziel_y,zieh_name,true);
				}
				forcerender=true;
				do_playSound(2);
			}
		}

		for (i in 0...ziele.length){

			var gx = i%5;
			var gy = Math.floor(i/5);
			
			var px = 18 + 13*gx;
			var py = 216 - 10*gy;
			
			if (Mouse.leftclick()){
				if (Mouse.x>=(px-4)&&Mouse.y>=(py-2) && (Mouse.x<(px-2+9+2)) && (Mouse.y<(py-2+9))){
					LoadLevel(i);
				}
			}

			if (geloest[i]==ziele[i][0]){
				Gfx.drawimage(px,py,"level_geloest");

				
			} else {
				Gfx.drawimage(px,py,"level_ungeloest");
			}

			if (i==aktuellesZielIdx){
				Gfx.drawimage(px-2,py-2,"level_selector");
			}

		}
		if (zeigabout){
			IMGUI.tooltipstr=null;
		}
		IMGUI.zeigtooltip();
	}

}
