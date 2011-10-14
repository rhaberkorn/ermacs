%%% This module implements "setq"-like variables. But, this seems a bit
%%% distasteful because of concurrent updates and so on. Maybe there is
%%% better way to do variables in general (or just program-internal
%%% variables).

-module(edit_var).
-export([start_link/0]).
-export([lookup/1, lookup/2, set/2, add_to_list/2]).

-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-define(TABLE, edit_mem_var).

%%%----------------------------------------------------------------------
%%% API
%%%----------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, edit_var}, edit_var, [], []).

%% Return: Value | undefined
lookup(Name) ->
    lookup(Name, undefined).

lookup(Name, Default) ->
    case ets:lookup(?TABLE, Name) of
        [{_, Value}] ->
            Value;
        [] ->
            Default
    end.

set(Name, Value) ->
    gen_server:call(?MODULE, {set, Name, Value}).

add_to_list(Name, Value) ->
    gen_server:call(?MODULE, {add_to_list, Name, Value}).

%%%----------------------------------------------------------------------
%%% Callback functions from gen_server
%%%----------------------------------------------------------------------
init([]) ->
    ?TABLE = ets:new(?TABLE, [set, public, named_table]),
    {ok, undefined}.

handle_call({set, Name, Value}, _From, State) ->
    ets:insert(?TABLE, {Name, Value}),
    {reply, ok, State};

handle_call({add_to_list, Name, Value}, _From, State) ->
    case ets:lookup(?TABLE, Name) of
        [{_, List}] when is_list(List) ->
            ets:insert(?TABLE, {Name, include(List, Value)}),
            {reply, ok, State};
        [{_, _NonList}] ->
            {reply, {error, bad_type}, State};
        [] ->
            ets:insert(?TABLE, {Name, [Value]}),
            {reply, ok, State}
    end.

handle_cast(_Msg, State)  -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.

include([], Value)        -> [Value];
include([Value|T], Value) -> [Value|T];
include([H|T], Value)     -> [H|include(T, Value)].
