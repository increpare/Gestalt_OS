import haxegon.*;

class Sprite {

    public var name:String;//for ID purposes

    public var tilesetname:String;
    public var tilenum:Int;

    public var x:Float;
    public var y:Float;
    public var visible:Bool;
    public var alpha:Float;

    public function destroy(){
        SpriteManager.RemoveSprite(this);
    }

    public function new(name:String,tilesetname:String,tilenum:Int,x:Float,y:Float){
        this.name=name;
        this.tilesetname=tilesetname;
        this.tilenum=tilenum;
        this.x=x;
        this.y=y;
        this.alpha=1;
        this.visible=true;
    }
}

@:access(haxegon.Core)
@:access(haxegon.Gfx)
class SpriteManager {

    private static var sprites:Array<Sprite>;

    public static function enable(){
        sprites = [];
        Core.registerplugin("spritemanager", "0.1.0");
        //Core.extend_endframe(render);
    }
    
    public static function clear() {
        sprites.splice(0,sprites.length);
    }

    public static function AddSprite(name:String,tilesetname:String,tilenum:Int,x:Float,y:Float):Sprite
    {
        var s:Sprite = new Sprite(name,tilesetname,tilenum,x,y);
        sprites.push(s);
        return s;        
    }

    public static function RemoveSprite(s:Sprite){
        sprites.remove(s);
    }

    public static function render(){
        Gfx.imagecolor=0xffffff;
        for (s in sprites){
            if (s.alpha==0){
                continue;
            }
            Gfx.imagealpha=s.alpha;            
            Gfx.drawtile(s.x,s.y,s.tilesetname,s.tilenum);
            
        }
        Gfx.imagealpha=1;
    }
}