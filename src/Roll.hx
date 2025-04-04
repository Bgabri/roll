import haxe.macro.Type.Ref;
import haxe.Exception;

import bglib.cli.Exit;
import bglib.cli.Doc;
import bglib.cli.exceptions.MalformedRequest;
import bglib.macros.UnpackingException;

import tink.Cli;
import tink.cli.Rest;

using bglib.macros.UnPack;

typedef Die = {
    var rolls:Int;
    var size:Int;
    var bonus:Int;
    var throws:Int;
}

/**
 * dd
 **/
@:build(bglib.cli.BaseCommand.build(true, "roll"))
class Roll {
    /**
     * Animates the dice rolls.
    **/
    public var animate:Bool = false;

    /**
     * Calculates the total of each throw.
    **/
    public var total:Bool = false;

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

    /**
     * Rolls a set of dice.
     * @param die #d#+#x#, where # are ints
    **/
    function roll(die:String) {
        #if debug
        @SuppressWarning("checkstyle:Trace")
        trace(die);
        #end
        var reg = ~/(\d+)d(\d+)(\+(\d+))?(x(\d+))?/gi;
        if (!reg.match(die)) throw new MalformedRequest("Invalid die format.");
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

    static function create():Roll {
        return new Roll();
    }
}
