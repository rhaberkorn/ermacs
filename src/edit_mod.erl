-module(edit_mod).

-export([init/0, require/1, load/1]).

init() ->
    ets:new(?MODULE, [set, named_table, public]),
    ok.

require(Mod) ->
    case ets:lookup(?MODULE, Mod) of
	[] ->		% not initialised
	    case load(Mod) of
		ok ->
		    ok;
		{error, Reason} ->
		    {error, Reason}
	    end;
	[_] ->		% already initialised
	    ok
    end.

load(Mod) ->
    case catch Mod:mod_init() of
	ok ->
	    ets:insert(?MODULE, {Mod}),
	    ok;
	{'EXIT', {undef, _}} ->
	    {error, {missing, Mod, mod_init, 0}};
	{error, Reason} ->
	    {error, Reason};
	Unexpected ->
	    {error, {unexpected, Unexpected}}
    end.

