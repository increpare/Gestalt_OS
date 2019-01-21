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
      sprache:"en",
      audio:1,
      level:0,
      solved:[0,0,0,0,0,0]
  };

  
}