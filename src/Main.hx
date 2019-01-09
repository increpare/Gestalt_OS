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
import haxe.Json;
import js.Browser;

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
	public var editmodus:Bool=true;
	public var editor_tl_x:Int=1;
	public var editor_tl_y:Int=2;
	public var editor_br_x:Int=4;
	public var editor_br_y:Int=5;


	public var aktuellesZiel:Ziel;	
	public var aktuellesZielIdx=0;
	public var ziele:Array<String> = [
		"cy4:Ziely4:zielaau5hany3:s10nR2nhau5hanR2nR2nhau5hanR2nR2nhau5hanR2nR2nhau5hhy9:werkzeugeatttttttttttttttttttthg",
		"cy4:Ziely4:zielaay3:s12u2haR2u2haR2u2hhy9:werkzeugeatttttttttttttttttttthg",
		"cy4:Ziely4:zielaau4hau2y3:s15nhany3:s14u2hau4hhy9:werkzeugeattfftttftttttttttttthg"
	];


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

	public var i_spalten:Int=2;
	public var i_zeilen:Int=10;
	
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
			return;
		}

		aktuellesZielIdx=level;

		var ziel_s = ziele[aktuellesZielIdx];
	    var unserializer = new Unserializer(ziel_s);

		aktuellesZiel = unserializer.unserialize();

		neuesBlatt();

	}
	
		
	function setup(){
		undoStack=new Array<LevelZustand>();
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
					} else if (j<sp_spalten-1 && a[j+1][i]=="s6"&& f[j+1][i]==(frame-1)){
						fuellbar=true;
					} else if (i>0 && a[j][i-1]=="s6" && f[j][i-1]==(frame-1)){
						fuellbar=true;
					} else if (i<sp_zeilen-1 && a[j][i+1]=="s6"&& f[j][i+1]==(frame-1)){
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

	function tuePlatzierung(hoverziel_x:Int,hoverziel_y:Int,zieh_name:String,nachkram:Bool){	
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
			versuchfallenzulassen(hoverziel_x,hoverziel_y);
			versuchaufzuwachsen(hoverziel_x,hoverziel_y);

			szs_brett = animationen[animationen.length-1].nach_brett;

			zustandSpeichern();
		}
	}

	public static var farbe_desktop = 0x7869c4;
	public static var farbe_menutext = 0x9f9f9f;
	function init(){
		// Text.font = "dos";
		// Sound.play("t2");
		//Music.play("music",0,true);
		Gfx.resizescreen(354, 235,true);
		SpriteManager.enable();
		Particle.enable();
		// Text.font="nokia";
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
					zeile.push("s"+(index+1));
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

	var undoStack:Array<LevelZustand>;

	function zustandSpeichern(){
		var lzs = new LevelZustand();
		lzs.i=Copy.copy(szs_inventory);
		lzs.sp=Copy.copy(szs_brett);
		lzs.hash=Json.stringify([szs_inventory,szs_brett]);
		if (undoStack.length>0){
			if (undoStack[undoStack.length-1].hash==lzs.hash){
				return;//keine duplikaten
			}
		}
		undoStack.push(lzs);
	}
	
	function tueUndo(){
		animationen.splice(0,animationen.length);	
		animPos=0;		
		var curhash = Json.stringify([szs_inventory,szs_brett]);
		var i = undoStack.length-1;
		while (i>=0){
			var zs = undoStack[i];
			if (curhash!=zs.hash){
				szs_inventory=Copy.copy(zs.i);
				szs_brett=Copy.copy(zs.sp);
				return;
			} else {
				if (i>0){
					undoStack.splice(i,1);
				}
			}
			i--;
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
		ziele[aktuellesZielIdx]=s;
		Browser.alert(s);
		trace(s);
	}


	function versperre(i:Int,j:Int){
		trace("vs",i,j);
		aktuellesZiel.werkzeuge[i+i_spalten*j]=!aktuellesZiel.werkzeuge[i+i_spalten*j];
		if (aktuellesZiel.werkzeuge[i+i_spalten*j]==false){
			szs_inventory[j][i]=null;
		} else {
			szs_inventory[j][i]="s"+(i+i_spalten*j+1);
		}
	}

	function update() {	
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

		
		Gfx.clearscreen(Col.YELLOW);
		Gfx.drawimage(0,0,"bg");
	
		// Gfx.drawimage(7,7,"taste_t_bg_up");
		if (IMGUI.pressbutton(
				"neu",
				"taste_t_bg_up",
				"taste_t_bg_down",
				"icon_neu",
				248,209,
				Globals.S("Blatt entleeren (N)","Clear page (N)")
				)  
				|| Input.justpressed(Key.N)
				|| Input.justpressed(Key.R)
				)
		{
			neuesBlatt();
		}

		if (undoStack.length>1){
			if (IMGUI.pressbutton(
					"rückgängig",
					"taste_t_bg_up",
					"taste_t_bg_down",
					"icon_undo",
					268,209,
					Globals.S("Rueckgaengig (Z)","Undo (Z)")
					)
					|| Input.justpressed(Key.Z)
					|| Input.justpressed(Key.U)
					)
			{
					tueUndo();
			}
		} else {
			Gfx.drawimage(268,209,"keineundosmehr");
		}

		var aktuell_av:Bool = Globals.state.audio==1 ? true : false;
		var neuaudio:Bool = IMGUI.togglebutton(
			"audio",
			"taste_t_bg_up",
			"taste_t_bg_down",
			"icon_audio_aus",
			"icon_audio_an",
			288,
			209,
			aktuell_av,
			Globals.S("Audio: aus (M)","Audio: off (M)"),
			Globals.S("Audio: an (M)","Audio: on (M)")			
			);
		if (Input.justpressed(Key.M)){
			neuaudio=!aktuell_av;
		}
		
		var neu_av = neuaudio?1:0;
		if (neu_av!=Globals.state.audio){
			Globals.state.audio=neu_av;
			Save.savevalue("mwbaudio",Globals.state.audio);
		}

		var aktuell_sprache:Bool = Globals.state.sprache==1 ? true : false;
		var neusprache:Bool = IMGUI.togglebutton(
			"sprache",
			"taste_t_bg_up",
			"taste_t_bg_down",
			"icon_flagge_de",
			"icon_flagge_en",
			308,209,
			aktuell_sprache,
			Globals.S("Sprache: Deutsch","Language: German"),
			Globals.S("Sprache: Englisch","Language: English")	
			);

		var neu_spr = neusprache?1:0;
		if (neu_spr!=Globals.state.sprache){
			Globals.state.sprache=neu_spr;
			Save.savevalue("mwbsprache",Globals.state.sprache);
		}

		IMGUI.pressbutton(
			"hilfe",
			"taste_t_bg_up",
			"taste_t_bg_down",
			"icon_hilfe",
			328,209,
			Globals.S("Ueber diese Anwendung","About this app")
			);

		Text.display(9,9,Globals.S("Wkzge","Tools"),farbe_menutext);


		var lebende = Lambda.count(Globals.state.solved, (w)->w==0);
		var titeltext="";
		if (lebende>1){
			titeltext = Globals.S("Werkbank","Workbench");// + " (" + lebende + Globals.S(" leben noch"," still live")+")." ;
		} else {
			titeltext = Globals.S("Werkbank","Workbench");// + " (" + lebende + Globals.S(" lebt noch"," still lives")+")." ;
		}
		Text.display(53,9,titeltext,farbe_menutext);

		Text.display(249,9,Globals.S("Ziel","Goal"),farbe_menutext);

		if(IMGUI.pressbutton("menü_l","taste_t_bg_up","taste_t_bg_down","icon_sm_l",248,182)){
			if (aktuellesZielIdx>0){
				LoadLevel(aktuellesZielIdx-1);
			}
		}
		if(IMGUI.pressbutton("menü_r","taste_t_bg_up","taste_t_bg_down","icon_sm_r",328,182)){

			if (aktuellesZielIdx+1<ziele.length){
				LoadLevel(aktuellesZielIdx+1);
			}
		}

		// Gfx.drawimage(Mouse.x-3,Mouse.y-3,"cursor_finger");


		for (j in 0...i_zeilen){
			for (i in 0...i_spalten){
				var index = i+i_spalten*j +1;
				var inhalt = szs_inventory[j][i];
				
				var ix = 8+19*i;
				var iy = 21+19*j;
				
				if (inhalt!=null){
					if (IMGUI.clickableimage(
							"icons/"+inhalt,
							ix,
							iy)){
						zieh_name = szs_inventory[j][i];
						szs_inventory[j][i] = null;
						zieh_modus=true;
						zieh_offset_x=(ix)-Mouse.x;
						zieh_offset_y=(iy)-Mouse.y;
						zieh_quelle_i=i;
						zieh_quelle_j=j;
					}
				} else {
					Gfx.drawimage(ix,iy,"schatten/s"+index);
					if (aktuellesZiel.werkzeuge[index-1]==false){
						Gfx.drawimage(ix,iy,"versperrt");
					}
				}
				if (editmodus){
					if (IMGUI.mouseover(
							"schatten/s"+index,
							ix,
							iy) &&
						Input.justpressed(Key.E) )
					{
						versperre(i,j);
					}
				}
				
			}
		}

		//ziel zeigen
		{
			var alevel = aktuellesZiel;
			var z_raster = alevel.ziel;
			var z_w = z_raster[0].length;
			var z_h = z_raster.length;

			var zielb_x=246;
			var zielb_y=19;

			var zielb_w=103;
			var zielb_h=163;

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
					Gfx.fillbox(52+19*i,21+19*j,16,16,0x6a6a6a);
					Gfx.drawimage(52+19*i,21+19*j,"icons/"+inhalt);
				}
				if (abw==frame){
					Gfx.drawimage(52+19*i,21+19*j,"cursor_aktiv");
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

				var ox = mx-51;
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
				Gfx.drawbox(51+editor_tl_x*19-1,20+editor_tl_y*19-1,b_w,b_h,Col.RED);
			}
		}
		
		if (zieh_modus==true){

			var hoverziel_x=-1;
			var hoverziel_y=-1;
			var geltendes_hoverziel=false;

			var mx=Mouse.x;
			var my=Mouse.y;

			var ox = mx-51;
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
					Gfx.drawimage(52+19*hoverziel_x,21+19*hoverziel_y,"zelle_hervorhebung");
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
			}
		}
		IMGUI.zeigtooltip();
	}

}
