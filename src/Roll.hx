import bglib.cli.exceptions.MalformedRequest;

using bglib.utils.PrimitiveTools;

/**
 * Represents a die.
**/
typedef Die = {
    var rolls:Int;
    var size:Int;
    var bonus:Int;
    var throws:Int;
}

/**
 * Usage:
 *     roll [flags] <die-str>
 *         <die-str> ::= <int> 'd' <int> <bonus>? <throws>?
 *           <bonus> ::= '+' <int>
 *          <throws> ::= 'x' <int>
 *     for example: roll 2d6+1x3
**/
@:build(bglib.cli.BaseCommand.build(true, "roll"))
@:build(bglib.macros.ExceptionHandler.handle())
class Roll {
    /**
     * calculate the total of each throw.
    **/
    public var total:Bool = false;

    function rollDie(die:Die):Int {
        if (die.size <= 0) return die.bonus;
        return Std.random(die.size) + 1 + die.bonus;
    }

    function throwDie(die:Die):Array<Int> {
        var rolls:Array<Int> = [];
        for (i in 0...die.rolls) {
            rolls.push(rollDie(die));
        }
        return rolls;
    }

    function throwDice(die:Die) {
        var rolls:Array<Array<Int>> = [];
        for (i in 0...die.throws) {
            rolls.push(throwDie(die));
        }

        var ls = rolls.tabular();
        if (!total) {
            Sys.println(ls.join("\n"));
            return;
        }
        var totals = rolls.map((rs) -> rs.fold((a, b) -> a + b, 0));
        for (i => l in ls) {
            Sys.println('$l (total: ${totals[i]})');
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
