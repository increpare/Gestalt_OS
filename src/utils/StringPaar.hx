package utils;

import haxegon.*;
import Globals.*;

class StringPaar
{
    public var de:String;
    public var en:String; 

    public function new(_de:String,_en:String){
        this.de=_de;
        this.en=_en;
    }

    public function Ausw():String{
        return S(de,en);
    }
}