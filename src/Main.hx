import js.html.Audio;
import haxe.rtti.XmlParser;
import haxe.ds.Vector;
import js.html.svg.AnimatedBoolean;
import haxegon.*;
import utils.*;
import StringTools;
import haxe.Serializer;
import haxe.Unserializer;

class Main {

	function LoadLevel(level:Int){

	}

	function setup(){
		Globals.state.level=Save.loadvalue("mwblevel",0);
		Globals.state.audio=Save.loadvalue("mwbaudio",1);
		Globals.state.sprache=Save.loadvalue("mwbsprache",1);

		for(i in 0...6){
			Globals.state.solved[i]=Save.loadvalue("mwbsolved"+i,0);
		}

		LoadLevel(Globals.state.level);	
	}

	function reset(){
		setup();
	}

	public static var desktop_farbe = 0x7869c4;
	
	function init(){

		// Sound.play("t2");
		//Music.play("music",0,true);
		Gfx.resizescreen(312, 235,true);
		SpriteManager.enable();
		Particle.enable();
		Text.font="nokia";
		Gfx.clearcolor=Col.RED;// desktop_farbe;
		// Gfx.loadtiles("dice_highlighted",16,16);
		setup();
	}	



	function update() {	
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

	}

}
