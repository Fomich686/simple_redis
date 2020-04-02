-module(rabbit_mod).

-export([
          start/0,  
          send_msg/0, 
          recieve_msg/0]).

-include_lib("amqp_client/include/amqp_client.hrl").


start() ->
  spawn(fun()-> send_msg() end),
  spawn(fun()-> recieve_msg() end).
  

send_msg()-> 
  {ok, Connection} =
        amqp_connection:start(#amqp_params_network{host = "localhost"}),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),

    amqp_channel:cast(Channel,
                      #'basic.publish'{
                        exchange = <<"">>,
                        routing_key = <<"hello">>},
                      #amqp_msg{payload = <<"Hello World!">>}),
    io:format(" [x] Sent 'Hello World!'~n"),
    ok = amqp_channel:close(Channel),
    ok = amqp_connection:close(Connection),
    ok.

recieve_msg()-> 
  {ok, Connection} =
        amqp_connection:start(#amqp_params_network{host = "localhost", heartbeat = 30}),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),
    io:format(" [*] Waiting for messages. To exit press CTRL+C~n"),

    Method = #'basic.consume'{queue = <<"hello">>, no_ack = true},
    amqp_channel:subscribe(Channel, Method, self()),
    loop(Channel).

loop(Channel) ->
    receive
        #'basic.consume_ok'{} ->
            io:format(" [x] Saw basic.consume_ok~n"),
            loop(Channel);
        {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
            io:format(" [x] Received ~p~n", [Body]),
            loop(Channel)
    end.