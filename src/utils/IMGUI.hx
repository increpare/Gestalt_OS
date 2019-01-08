package utils;

import haxegon.*;
import Globals.*;

class IMGUI {


	private static var downstates:Map<String,Bool> = new Map<String,Bool>();


	public static function clickableimage(
		im:String,
		x:Int,
		y:Int
		) : Bool
	{
		
		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(im);
	 	var h = Gfx.imageheight(im);


		Gfx.drawimage(
			x,
			y,
			im
			);
	
		var over:Bool = dx>=0&& dy>=0 && dx<w && dy<h;

		var mouseclicked = Mouse.leftclick();
		// var mousedown = Mouse.leftheld()||mouseclicked;
		// var clicked=false;
		return over && mouseclicked;

	}

	public static function pressbutton(
		id:String,
		bg:String,
		bg_pressed:String,
		im:String,
		x:Int,
		y:Int
		) : Bool
	{
		
		if (downstates.exists(id)==false){
			downstates.set(id,false);
		}
		var downstate:Bool = downstates.get(id);
		
		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(bg);
	 	var h = Gfx.imageheight(bg);
		var over:Bool = dx>=0&& dy>=0 && dx<w && dy<h;

		var mouseclicked = Mouse.leftclick();
		var mousedown = Mouse.leftheld()||mouseclicked;
		var clicked=false;
		if (over){
			if (downstate==false){
				if (mouseclicked){
					downstate=true; 
				}
			} else {//downstate==true
				if (mousedown==false){
					if (downstate){
						downstate=false;
						clicked=true;
					}
				}
			}
		} else {
			if (mousedown==false){
				downstate=false;	//no click
			}
		}

		Gfx.drawimage(
			x,
			y,
			downstate?bg_pressed:bg
			);
	
		Gfx.drawimage(
			x+(downstate?1:0),
			y+(downstate?1:0),
			im
			);

		downstates.set(id,downstate);
		return clicked;
	}

	public static function togglebutton(
		id:String,
		bg:String,
		bg_pressed:String,
		im_0:String,
		im_1:String,
		x:Int,
		y:Int,
		state:Bool//img0 or img1
		) : Bool
		{
		
		if (downstates.exists(id)==false){
			downstates.set(id,false);
		}
		var downstate = downstates.get(id);

		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(bg);
	 	var h = Gfx.imageheight(bg);
		var over:Bool = dx>=0&& dy>=0 && dx<w && dy<h;

		var mouseclicked = Mouse.leftclick();
		var mousedown = Mouse.leftheld()||mouseclicked;

		if (over){
			if (downstate==false){
				if (mouseclicked){
					downstate=true; 
				}
			} else {//downstate==true
				if (mousedown==false){
					if (downstate){
						downstate=false;
						state=!state;
					}
				}
			}
		} else {
			if (mousedown==false){
				downstate=false;	//no click
			}
		}

		Gfx.drawimage(
			x,
			y,
			downstate?bg_pressed:bg
			);
	
		Gfx.drawimage(
			x+(downstate?1:0),
			y+(downstate?1:0),
			state?im_1:im_0
			);

		downstates.set(id,downstate);
		return state;
	}


	public static function pushbutton(
		id:String,
		bg:String,
		bg_pressed:String,
		im:String,
		x:Int,
		y:Int,
		state:Bool//img0 or img1
		) : Bool
		{
		
		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(bg);
	 	var h = Gfx.imageheight(bg);
		var over:Bool = dx>=0&& dy>=0 && dx<w && dy<h;

		var mouseclicked = Mouse.leftclick();
		var mousedown = Mouse.leftheld()||mouseclicked;

		if (over && mouseclicked){
			state=!state;
		}
			

		var downstate=state;
		Gfx.drawimage(
			x,
			y,
			downstate?bg_pressed:bg
			);
			
		Gfx.drawimage(
			x+(downstate?1:0),
			y+(downstate?1:0),
			im
			);

		return state;
	}
}