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
//de, en, es, fr
  public static function S(de:String,en:String, es:String, fr:String):String{
      switch(state.sprache){
          case 0:
            return en;
          case 1:
            return de;
          case 2:
            return es;
          case 3:
            return fr;
      }
      trace("ERROR state.sprache = "+state.sprache);
      return "";
  }
}