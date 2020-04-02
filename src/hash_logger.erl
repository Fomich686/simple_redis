-module(hash_logger).

-behaviour(gen_event).

-export([
          init/1, 
          terminate/2, 
          handle_event/2, 
          handle_info/2,
          handle_call/2
        ]).

init(standart_io) ->
  io:format("standart_io ~n"),
  {ok, {standart_io, 1}};
init({file, File}) ->
  io:format("file ~n"),
  {ok, Fd} = file:open(File, write),
  {ok, {Fd, 1}};
init(Args) ->
  {error, {args, Args}}.

terminate(_Reason, {standart_io, Count}) ->
  {count, Count};
terminate(_Reason, {Fd, Count}) ->
  file:close(Fd),
  {count, Count}.

handle_call(_Request, State) ->
  {reply, ok, State}.

handle_event(Event, {Fd, Count}) ->
  io:format(Fd,"Id:~p Time:~p Date:~p  ~p ~n",[Count, time(), date(),Event]),
  {ok, {Fd, Count + 1}}.

handle_info(Event, {Fd, Count}) ->
  io:format(Fd,"Id:~p Time:~p Date:~p  Unknown: ~p ~n",[Count, time(), date(),Event]),
  {ok, {Fd, Count + 1 }}.
