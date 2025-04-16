import bglib.ExceptionHandler;
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
@:baseCommand(true, "roll")
class Roll implements ExceptionHandler implements bglib.cli.BaseCommand {
    /**
     * calculate the total of each throw.
    **/
    public var total:Bool = false;

    /**
     * Generate rolls from ANU QRNG
    **/
    public var qrand:Bool = false;

    function rollDie(die:Die):Int {
        if (die.size <= 0) return die.bonus;
        var v = 0;
        if (qrand) {
            try {
                v = QRand.get(die.size);
            } catch (e) {
                v = Std.random(die.size);
            }
        } else v = Std.random(die.size);

        return v + 1 + die.bonus;
    }

    function throwDie(die:Die):Array<Int> {
        var rolls:Array<Int> = [];
        for (i in 0...die.rolls) {
            rolls.push(rollDie(die));
        }
        return rolls;
    }

    function throwDice(die:Die) {
        if (qrand) QRand.buffer(die.size, die.throws * die.rolls);
        var rolls:Array<Array<Int>> = [];
        for (i in 0...die.throws) {
            rolls.push(throwDie(die));
        }

        var totals = rolls.map((rs) -> rs.fold((a, b) -> a + b, 0));
        var rolls = rolls.map((rs) -> rs.map((r) -> '$r'));
        if (total) {
            var header = [for (i in 0...die.rolls) ""];
            header.push("total");
            rolls.mapi((i, rs) -> rs.push(Std.string(totals[i])));
            rolls.unshift(header);
        }
        var ls = rolls.tabular(" │ ");
        ls = ls.map(s -> '│ $s │');
        if (total) ls[0] = ls[0].replace("│", " ");
        Sys.println(ls.join("\n"));
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
}
