-module(edit_input).

-include("edit.hrl").

-export([start_link/1, loop/1]).

%% Receiver will be sent {key_input, Char} each time a key is pressed.
start_link(Receiver) ->
    Pid = spawn_link(edit_input, loop, [Receiver]),
    register(?MODULE, Pid),
    Pid.

loop(Receiver) ->
    Ch = case ?EDIT_TERMINAL:read() of
	     $\n ->
		 $\r;
	     145 ->			% C-M-q is reserved for panic
		 panic();
	     X ->
		 X
	 end,
    Receiver ! {key_input, Ch},
    loop(Receiver).

panic() ->
    halt().
