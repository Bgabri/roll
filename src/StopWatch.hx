import haxe.Timer;

/**
 * class Main
 *     colour = red
 *     onKeyPress(key):
 *         colour = green
 *
 *     loop true:
 *         clear()
 *         cPrint(colour, "hi")
 *
 * class Listener:
 *     loop true:
 *         char = input()
 *         thread.main.onKeyPress(char)
 *
 **/
class StopWatch {
    var t:Float = 0.;
    var timer:Timer;
    public function new() {
        timer = new Timer(500);
        timer.run = timerRun;
    }

    function timerRun() {
        t += 0.50;
        trace(t);
    }

    public static function main() {
        new StopWatch();
    }
}
