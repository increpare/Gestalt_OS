package;
import haxegon.*;

#if js
import js.Browser;
#end


class Globals
{

    public static function mPlayNote(seed:Int,frequency:Float,length:Float,volume:Float){
        #if js
        untyped playNote(seed,frequency,length,volume/2);
        #end
    }

  public static var state = {
      sprache:0,
      audio:1,
      level:0,
      solved:[0,0,0,0,0,0]
  };

  public static function S(de:String,en:String):String{
      if (state.sprache==0){
          return de;
      } else {
        return en;
      }
  }
}