# Roll
A cli for rolling a die string.

# Compiling
```
haxe compile.hxml
```
depends on [bglib](https://github.com/Bgabri/bglib)

# Usage
```
Usage:
    roll [flags] <die-str>
        <die-str> ::= <int> 'd' <int> <bonus>? <throws>?
          <bonus> ::= '+' <int>
         <throws> ::= 'x' <int>
    for example: roll 2d6+1x3
flags:
    --total, -t
        calculate the total of each throw.
    --qrand, -q
        generate rolls from http://qrandom.io
    --help, -h
        prints this help message
```
