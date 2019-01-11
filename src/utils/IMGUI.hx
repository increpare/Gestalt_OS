package utils;

import haxegon.*;
import Globals.*;

class IMGUI {


	private static var downstates:Map<String,Bool> = new Map<String,Bool>();

	public static function mouseover(
		im:String,
		x:Int,
		y:Int
		) : Bool
	{
		
		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(im);
	 	var h = Gfx.imageheight(im);


	
		var over:Bool = dx>=0&& dy>=0 && dx<w && dy<h;

		return over;

	}


	public static function clickableimage(
		im:String,
		x:Int,
		y:Int,
		?editkey:Key,
		?editcallback:Void->Void
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
		if (editkey!=null){
			if (over && Input.justpressed(editkey)){
				editcallback();
			}
		}
		return over && mouseclicked;

	}

	public static var tooltipstr:String=null;
	public static function zeigtooltip(){
		if (tooltipstr==null){
			return;
		}

		var x = Mouse.x;
		var y = Mouse.y;

		var w = Math.ceil(Text.width(tooltipstr));
		var h = Math.ceil(Text.height(tooltipstr));
		var mx_l=4;
		var mx_r=3;
		var my_t=3;
		var my_b=3;

		var b_w=w+mx_l+mx_r;
		var b_h =h+my_t+my_b;
		x-=b_w-1;
		y-=b_h-1;
		Gfx.fillbox(x,y,b_w,b_h,0x035766);
		Gfx.drawbox(x,y,b_w,b_h,0xbfbfbf);
		Text.display(x+mx_l,y+my_t,tooltipstr,0x9f9f9f);
		tooltipstr=null;	
	}

	public static function pressbutton(
		id:String,
		bg:String,
		bg_pressed:String,
		im:String,
		x:Int,
		y:Int,
		?tooltip:String
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
		if (over && !mousedown && tooltip!=null){
			tooltipstr=tooltip;	
		}
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
			(downstate&&over)?bg_pressed:bg
			);
	
		Gfx.drawimage(
			x+((downstate&&over)?1:0),
			y+((downstate&&over)?1:0),
			im
			);

		downstates.set(id,downstate);
		return clicked;
	}


	public static function presstextbutton(
		id:String,
		bg:String,
		bg_pressed:String,
		text:String,
		color:Int,
		x:Int,
		y:Int,
		?tooltip:String
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
		if (over && !mousedown && tooltip!=null){
			tooltipstr=tooltip;	
		}
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
			(downstate&&over)?bg_pressed:bg
			);
	

		var tw = Text.width(text);
		var th = Text.height(text);
		var tx = x+w/2-tw/2+((downstate&&over)?1:0);
		var ty = y+h/2-th/2+((downstate&&over)?1:0);
		Text.display(tx,ty,text,color);


		downstates.set(id,downstate);
		return clicked;
	}



	public static function presstextbutton_disabled(
		id:String,
		bg:String,
		bg_pressed:String,
		text:String,
		color:Int,
		x:Int,
		y:Int,
		?tooltip:String
		) 
	{
		

		var dx = Mouse.x-x;
		var dy = Mouse.y-y;
	 	var w = Gfx.imagewidth(bg);
	 	var h = Gfx.imageheight(bg);
		

		Gfx.drawimage(
			x,
			y,
			bg
			);
	

		var tw = Text.width(text);
		var th = Text.height(text);
		var tx = x+w/2-tw/2;
		var ty = y+h/2-th/2;
		Text.display(tx,ty,text,color);
	}

	public static function togglebutton(
		id:String,
		bg:String,
		bg_pressed:String,
		im_0:String,
		im_1:String,
		x:Int,
		y:Int,
		state:Bool,//img0 or img1
		?tooltip_0:String,	
		?tooltip_1:String	
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
		if (over&&!mousedown){
			tooltipstr=state?tooltip_1:tooltip_0;	
		}
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
			(downstate&&over)?bg_pressed:bg
			);
	
		Gfx.drawimage(
			x+((downstate&&over)?1:0),
			y+((downstate&&over)?1:0),
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
			(downstate&&over)?bg_pressed:bg
			);
			
		Gfx.drawimage(
			x+((downstate&&over)?1:0),
			y+((downstate&&over)?1:0),
			im
			);

		return state;
	}
}