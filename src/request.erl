-module(request).

-export([
          gen/1
          %get_cast/1,
          %get_call/1
        ]).

gen(N)->
  Http = "https://jsonplaceholder.typicode.com/todos/", %++integer_to_list(Id)
  [get_cast(Http ++ integer_to_list(Id)) || Id <- lists:seq(1,N)].

get_cast(Request) ->
          Pid = poolboy:checkout(pool2),
          %gen_event:notify(my_event, {pid, Pid}),
          gen_server:cast(Pid, {request, Request}).
          
  
get_call(Request) ->
  Pid = poolboy:checkout(pool2),
  Res = gen_server:call(Pid, {request, Request}),
  io:format("get_call: ~p ~p ~n",[Pid,Res]),
  poolboy:checkin(pool2,Pid).