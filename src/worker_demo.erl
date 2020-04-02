-module(worker_demo).

-behaviour(gen_server).
-behavior(poolboy_worker).

-export([start_link/1]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-export([
        add/1
        ]).

add(Data)->
  gen_server:call(?MODULE, Data).

start_link(Args) ->
    io:format("Args: ~p~n",[Args]),
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    io:format("Pid: ~p~n",[self()]),
    {ok, #{}}.

handle_call(Request, From, State) ->
    io:format("From: ~p~n",[From]),
    NewState = [Request| State],
    {reply, NewState, NewState}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
