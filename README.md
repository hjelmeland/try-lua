Pure Lua equivalent of lua-try ( <https://github.com/moteus/lua-try> ) ,
which again is based on 
[luasockets]( http://w3.impa.br/~diego/software/luasocket/socket.html )
newtry, protect and try functions.
Passes the excellent lunitx test of lua-try.

fix_return_values() trick taken from <http://lua-users.org/wiki/FinalizedExceptions>. 
This page also explains the idea behind the thing. 

This pure Lua version can be nice if you want to avoid cross compilation, or
you want to understand how  newtry, protect and try works if you are not so
fluent in the Lua C API. (Both applied to me).

Note: Unlike lua-try, I chose to use an unique metatable instead of an unique 
table key to tag newtry errors. This saves one if-clause in protect().
But then try/co.lua had to be modified.

#About newtry()/protect()

The short story is that you can use can __newtry(finalizer)__ to make a function wrapper 
that can be applied on functions that uses the idiomatic Lua "return nil, error_msg" 
convention on exceptions. If exception (that is that the first return value is falsy), 
then _finalizer()_ is run (cleaning up your resources), and Lua __error(error_msg)__
 is raised. The error_msg is wrapped and tagged so that it can be caught by 
 try.protect()(...).

Then __protect(func)__ can be used to wrap function _func_ so that it catches
errors made from underlying try.newtry()(...) exceptions. 
If the error() came from a try.newtry()(...)
exception, then the exception is converted back to idiomatic "return nil, error_msg".
Other errors are passed on by calling Lua error() again.


