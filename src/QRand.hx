import haxe.Http;

using bglib.utils.PrimitiveTools;

private typedef QResponse = {
    var id:String;
    var message:String;
    var signature:String;
    var resultType:String;
    var timeStamp:Date;
    var elapsedTime:Float;
    var ?number:Int;
    var ?numbers:Array<Int>;
}

/**
 * Generates random numbers using qrandom.io.
**/
class QRand {
    static var cache:Map<Int, Array<Int>> = [];

    static function request(min:Int, max:Int, n:Int = 0):QResponse {
        #if debug
        @SuppressWarning("checkstyle:Trace")
        trace('QRand.request: min: $min, max: $max, n: $n');
        #end
        var url = "https://qrandom.io/api/random/int";
        if (n > 0) url += "s";
        var req = new Http(url);
        req.setParameter("min", Std.string(min));
        req.setParameter("max", Std.string(max));
        if (n > 0) {
            req.setParameter("n", Std.string(n));
        }
        var response:QResponse;
        req.onData = (data) -> {
            response = haxe.Json.parse(data);
        };
        req.onError = error -> throw error;

        req.request(false);
        return response;
    }

    /**
     * Generates a random quantum number.
     * from 0 to x.
     * @param x max value (exclusive)
     * @return Int
    **/
    public static function get(x:Int):Int {
        if (!cache[x].empty()) {
            return cache[x].pop();
        }
        return request(0, x).number;
    }

    /**
     * Buffers n random numbers from 0 to x.
     * @param x max value (exclusive)
     * @param n number of random numbers to buffer
     **/
    public static function buffer(x:Int, n:Int) {
        var response = request(0, x, n);
        if (!cache.exists(x)) {
            cache.set(x, []);
        }
        cache[x] = cache[x].concat(response.numbers);
    }
}
