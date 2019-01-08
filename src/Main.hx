import js.html.Audio;
import haxe.rtti.XmlParser;
import haxe.ds.Vector;
import js.html.svg.AnimatedBoolean;
import haxegon.*;
import utils.*;
import StringTools;
import haxe.Serializer;
import haxe.Unserializer;
import lime.ui.Window;

/*
credits

testing/feedback:
daniel frier

rest:
increpare

*/

@:access(lime.ui.Window)

class AnimationFrame {
	public var vor_brett:Array<Array<String>>;
	public var nach_brett:Array<Array<String>>;
	public var abweichung:Array<Array<Int>>;
	public var maxabweichung:Int;
	public function new(){
		
	}
}

class Main {

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
	
	function LoadLevel(level:Int){

	}
	
		
	function setup(){
		animationen = new Array<AnimationFrame>();
		zieh_modus=false;

		Globals.state.level=Save.loadvalue("mwblevel",0);
		Globals.state.audio=Save.loadvalue("mwbaudio",1);
		Globals.state.sprache=Save.loadvalue("mwbsprache",1);

		for(i in 0...6){
			Globals.state.solved[i]=Save.loadvalue("mwbsolved"+i,0);
		}

		LoadLevel(Globals.state.level);	

		szs_inventory = new Array<Array<String>>();
		for (j in 0...i_zeilen){
			var zeile = new Array<String>();
			for (i in 0...i_spalten){
				var index = i+i_spalten*j+1 ;
				zeile.push("s"+index);
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
	}

	function reset(){
		setup();
	}

	public static var animFrameDauer:Int=10;
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

	function spiralen(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
		var x= hoverziel_x;
		var y = hoverziel_y;
		var frame=0;
		y--;

		//heroben
		while (y>0){
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


	function spiegeln_hinunten(anim:AnimationFrame,hoverziel_x:Int,hoverziel_y:Int){
	
	
		var max_frame=0;

		for (j in 0...sp_zeilen){
			var j_von=hoverziel_y-j;
			var j_zu=hoverziel_y+j;
			if (j_von>0 && j_von<sp_zeilen){
				for (x in 0...sp_spalten){
					anim.abweichung[j_von][x]=j;
					if (j>max_frame){
						max_frame=j;
					}
				}
			}
			if (j_zu>0 && j_zu<sp_zeilen){
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

			if (j_von>0 && j_von<sp_zeilen && j_zu>0 && j_zu<sp_zeilen){
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

	function tuePlatzierung(hoverziel_x:Int,hoverziel_y:Int,zieh_name:String){	
		var startframe = new AnimationFrame();
		startframe.vor_brett = Copy.copy(szs_brett);

		szs_brett[hoverziel_y][hoverziel_x]=zieh_name;

		startframe.nach_brett = Copy.copy(szs_brett);
		startframe.abweichung = leererAbweichungsgitter();
		startframe.abweichung[hoverziel_y][hoverziel_x]=0;
		startframe.maxabweichung=0;
		var animation = startframe;
		animationen.push(animation);

		switch(zieh_name){
			case "s1":

			case "s2":
			
			case "s3":
			
			case "s4":
			
			case "s5":
				spazieren(animation,hoverziel_x,hoverziel_y);
			case "s6":
			
			case "s7":
			
			case "s8":
			
			case "s9":
			
			case "s10":
			
			case "s11":
			
			case "s12":
				spiralen(animation,hoverziel_x,hoverziel_y);	
			
			case "s13":
			
			case "s14":
			
			case "s15":
			
			case "s16":
				spiegeln_hinunten(animation,hoverziel_x,hoverziel_y);		
			case "s17":
				spiegeln_hinoben(animation,hoverziel_x,hoverziel_y);
			case "s18":
			
			case "s19":
			
			case "s20":
			
		}
		szs_brett = startframe.nach_brett;
	}

	public static var farbe_desktop = 0x7869c4;
	public static var farbe_menutext = 0x9f9f9f;
	function init(){
		// Text.font = "dos";
		// Sound.play("t2");
		//Music.play("music",0,true);
		Gfx.resizescreen(312, 235,true);
		SpriteManager.enable();
		Particle.enable();
		// Text.font="nokia";
		// Gfx.clearcolor=Col.RED;// desktop_farbe;
		// Gfx.loadtiles("dice_highlighted",16,16);
		setup();
	}	

	

	function update() {	
		if (Mouse.leftclick()){
			animationen.splice(0,animationen.length);
		}
		if (animationen.length>0){
			var animation=animationen[0];
			animPos++;
			if (animPos>animFrameDauer*(animation.maxabweichung+1)){
				animationen.shift();		
				animPos=0;		
			}
		}

		
		Gfx.clearscreen(Col.YELLOW);
		Gfx.drawimage(0,0,"bg");
	
		// Gfx.drawimage(7,7,"taste_t_bg_up");
		IMGUI.pressbutton("neu","taste_t_bg_up","taste_t_bg_down","icon_neu",8,8);
		IMGUI.pressbutton("rückgängig","taste_t_bg_up","taste_t_bg_down","icon_rueckgaengig",8,28);
		var aktuell_av:Bool = Globals.state.audio==1 ? true : false;
		var neuaudio:Bool = IMGUI.togglebutton("audio","taste_t_bg_up","taste_t_bg_down","icon_audio_aus","icon_audio_an",8,48,aktuell_av);
		var neu_av = neuaudio?1:0;
		if (neu_av!=Globals.state.audio){
			Globals.state.audio=neu_av;
			Save.savevalue("mwbaudio",Globals.state.audio);
		}

		var aktuell_sprache:Bool = Globals.state.sprache==1 ? true : false;
		var neusprache:Bool = IMGUI.togglebutton("sprache","taste_t_bg_up","taste_t_bg_down","icon_flagge_de","icon_flagge_en",8,68,aktuell_sprache);
		var neu_spr = neusprache?1:0;
		if (neu_spr!=Globals.state.sprache){
			Globals.state.sprache=neu_spr;
			Save.savevalue("mwbsprache",Globals.state.sprache);
		}

		IMGUI.pressbutton("hilfe","taste_t_bg_up","taste_t_bg_down","icon_hilfe",8,88);

		Text.display(37,9,Globals.S("Sigilla","Sigils"),farbe_menutext);


		var ziele = Globals.state.solved.length;
		var lebende = Lambda.count(Globals.state.solved, (w)->w==0);
		var titeltext="";
		if (lebende>1){
			titeltext = Globals.S("Werkbank","Workbench") + " (" + lebende + Globals.S(" leben noch"," still live")+")." ;
		} else {
			titeltext = Globals.S("Werkbank","Workbench") + " (" + lebende + Globals.S(" lebt noch"," still lives")+")." ;
		}
		Text.display(119,9,titeltext,farbe_menutext);

		Text.display(37,123,Globals.S("Zauber","Magic"),farbe_menutext);

		IMGUI.pressbutton("menü_l","taste_sm_up","taste_sm_down","icon_sm_l",35,210);
		IMGUI.pressbutton("menü_r","taste_sm_up","taste_sm_down","icon_sm_r",91,210);

		// Gfx.drawimage(Mouse.x-3,Mouse.y-3,"cursor_finger");


		for (j in 0...i_zeilen){
			for (i in 0...i_spalten){
				var index = i+i_spalten*j+1 ;
				var inhalt = szs_inventory[j][i];
				if (inhalt!=null){
					if (IMGUI.clickableimage("icons/"+inhalt,35+19*i,21+19*j)){
						zieh_name = szs_inventory[j][i];
						szs_inventory[j][i] = null;
						zieh_modus=true;
						zieh_offset_x=(35+19*i)-Mouse.x;
						zieh_offset_y=(21+19*j)-Mouse.y;
						zieh_quelle_i=i;
						zieh_quelle_j=j;
					}
				} else {
					Gfx.drawimage(35+19*i,21+19*j,"schatten/s"+index);
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
					Gfx.fillbox(117+19*i,21+19*j,16,16,0x6a6a6a);
					Gfx.drawimage(117+19*i,21+19*j,"icons/"+inhalt);
				}
				if (abw==frame){
					Gfx.drawimage(117+19*i,21+19*j,"cursor_aktiv");
				}
			}
		}
		
		if (zieh_modus==true){

			var hoverziel_x=-1;
			var hoverziel_y=-1;
			var geltendes_hoverziel=false;

			var mx=Mouse.x;
			var my=Mouse.y;

			var ox = mx-116;
			var oy = my-20;
			var ox_d = ox % 19;
			var oy_d = oy % 19;

			var nope:Bool=false;
			if (ox_d<18 && oy_d<18){
				hoverziel_x=Math.floor(ox/19);
				hoverziel_y=Math.floor(oy/19);

				if (hoverziel_x>=0 && hoverziel_x<sp_spalten && hoverziel_y>=0 && hoverziel_y<sp_zeilen){
					geltendes_hoverziel=true;
				}
			}
			
			if (geltendes_hoverziel){
				if (szs_brett[hoverziel_y][hoverziel_x]==null){
					Gfx.drawimage(117+19*hoverziel_x,21+19*hoverziel_y,"zelle_hervorhebung");
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
					tuePlatzierung(hoverziel_x,hoverziel_y,zieh_name);
				}
			}
		}
	}

}
