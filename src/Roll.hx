
import tink.core.Error;
import tink.CoreApi.Noise;
import tink.CoreApi.Outcome;

import haxe.Rest;

import sys.thread.Lock;

import tui.Animation;

import tink.Cli;

import haxe.Timer;

typedef Die = {
    var rolls:Int;
    var size:Int;
    var bonus:Int;
    var throws:Int;
}

class SubCommand {
    public function new() {}

    @:defaultCommand
    public function run(rest:Rest<String>) {
        Sys.println('sub $rest');
    }
}

class Exit {
    public static function handler(result:Outcome<Noise, Error>) {
        switch result {
            case Success(_):
                Sys.exit(0);
            case Failure(e):
                trace(e.toString());
                // var message = e.message;
                // if (e.data != null) message += ', ${e.data}';
                // Sys.println(message);
                // Sys.exit(e.code);
        }
    }
}

/**
 * 
**/
class Roll {
    static function main() {
        Cli.process(Sys.args(), new Roll()).handle(function(o) {
            Exit.handler(o);
        });
    }

    /**
     * Animates the dice rolls.
    **/
    public var animate:Bool = false;

    /**
     * Calculates the total of each throw.
    **/
    public var total:Bool = false;

    private function new() {}

    function rollDie(die:Die):Int {
        return Std.random(die.size) + 1 + die.bonus;
    }

    function throwDie(die:Die) {
        var t = 0;
        for (i in 0...die.rolls) {
            var roll = rollDie(die);
            t += roll;
            if (i != 0) Sys.print(", ");
            Sys.print(roll);
        }
        if (total) Sys.print(' (total:$t)');
        Sys.print("\n");
    }

    function throwDice(die:Die) {
        for (i in 0...die.throws) {
            throwDie(die);
        }
    }

    @:command
    public var help = new SubCommand();

    /**
     * Rolls a set of dice.
     * @param die #d#+#x#, where # are ints
    **/
    @:defaultCommand
    public function roll(die:String) {
        #if debug
        @SuppressWarning("checkstyle:Trace")
        trace(die);
        #end
        var reg = ~/(\d+)d(\d+)(\+(\d+))?(x(\d+))?/gi;
        if (!reg.match(die)) {
            Sys.println("invalid");
            return;
        }
        var d:Die = {
            rolls: Std.parseInt(reg.matched(1)),
            size: Std.parseInt(reg.matched(2)),
            bonus: 0,
            throws: 1
        };
        if (reg.matched(4) != null) d.bonus = Std.parseInt(reg.matched(4));
        if (reg.matched(6) != null) d.throws = Std.parseInt(reg.matched(6));
        throwDice(d);
    }
}
