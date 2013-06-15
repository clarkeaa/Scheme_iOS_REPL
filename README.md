Scheme_iOS_REPL
===============

Sample of creating a scheme REPL that works over TCP on iOS for iPhone or iPad

Description
-----------
This is a weekend project where I got Chibi Scheme (https://code.google.com/p/chibi-scheme/) running on iOS.  It also has a TCP server so that you can connect to interact with it as a REPL.  After you are running the App go to Terminal and type in "telnet <iphone/iphonesim ip> 2048", from there you can type in something like "(+ 1 2 3 4)" and it will print back out "10".  It should also report reader/eval exceptions correctly as well.

Limitations
-----------
* I haven't spent much time making sure all errors and memory management are handled.  I just wanted a proof of concept for now so keep that in mind.
* only one person is allowed to connect at a time.
* extended fcall and huffman encoding are disabled to simplify chibi compilation
