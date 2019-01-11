import haxegon.*;

typedef FRange = {
	var min:Float;
	var max:Float;
}

typedef ParticleElem = {
    public var color:Int;

    public var gravityx:Float;
    public var gravityy:Float;

    public var lebenszeit:Float;
    public var maxLeben:Float;
    
    public var x:Float;
    public var y:Float;
    public var a:Float;

    public var velx:Float;
    public var vely:Float;
    public var vela:Float;

    public var startSize:Float;
    public var endSize:Float;
}


@:access(haxegon.Core)
@:access(haxegon.Gfx)
class Particle {

    static var particles:Array<ParticleElem>;

    public static function active():Bool{
        return particles.length>0;
    }
    
    public static function enable(){
        particles = [];
        Core.registerplugin("particle", "0.1.0");
        Core.extend_endframe(render);
    }
    
    private static function randFRange(f:FRange){
        return Random.float(f.min,f.max);
    }

    public static function clear() {
        particles.splice(0,particles.length);
    }

    public static function GenerateParticles(
        x:FRange,
        y:FRange,
        color:Int,
        count:Int,
        gravityx:Float,
        gravityy:Float,
        lebenzeit:FRange,
        angle:FRange,
        velx:FRange,
        vely:FRange,
        vela:FRange,
        startSizeRange:FRange,
        endSizeRange:FRange
        ) 
    {
        for (i in 0...count){
            var _lebenzeit=randFRange(lebenzeit);

            particles.push(
                    {  
                        color:color,
                        gravityx:gravityx,
                        gravityy:gravityy,

                        lebenszeit:_lebenzeit,
                        maxLeben:_lebenzeit,

                        x:randFRange(x),
                        y:randFRange(y),            
                        a:randFRange(angle),

                        velx:randFRange(velx),
                        vely:randFRange(vely),
                        vela:randFRange(vela),
    
                        startSize: randFRange(startSizeRange),
                        endSize: randFRange(endSizeRange),
                    }
                );
        }
    }

    public static function forcerender(){
        rendered=false;
        render();
        rendered=true;
    }

    private static var rendered:Bool=false;
    private static function render(){
        if (rendered){
            rendered=false; 
            return;
        }
        var fps = Core.fps;
        var delta=1/fps;

        var i = particles.length;
        while (--i > 0){
            var p = particles[i];

            p.lebenszeit-=delta;

            if (p.lebenszeit<=0){
                particles.splice(i,1);
                continue;
            }

            //update velocity
            p.velx+=delta*p.gravityx;
            p.vely+=delta*p.gravityy;

            //update position
            p.x+=delta*p.velx;
            p.y+=delta*p.vely;
            p.a+=delta*p.vela;
            
            var t1 = p.lebenszeit/p.maxLeben;
            var t2 = 1-t1;

            var scale = p.startSize*t1+p.endSize*t2;

            //draw
            Gfx.rotation(p.a);
            Gfx.scale(scale);
            Gfx.fillbox(p.x-scale/2,p.y-scale/2,scale,scale,p.color);
        }

        Gfx.scale(1);
        Gfx.rotation(0);     
    }
}