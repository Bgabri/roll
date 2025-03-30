package tui;

import haxe.Timer;

class Animation extends Timer {
    var frameIndex:Int = 0;
    var frames:Array<Trees>;
    var loop:Bool = true;

    /**
     * Adds a new frame to the animation.
     * @param frame to add
     **/
    public function addFrame(frame:Trees) {
        frames.push(frame);
    }

    public function new(?frames:Array<Trees>, length = 500) {
        if (frames == null) frames = [];
        this.frames = frames;
        super(length);
    }

    override function run() {
        frameIndex++;
        if (frameIndex >= frames.length) {
            if (loop) frameIndex = 0;
            else this.stop();
        }
        Sys.print(Ansi.clear);
        Sys.println(frames[frameIndex].toString());
    }
}
