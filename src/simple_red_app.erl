-module(simple_red_app).

-behaviour(application).

-export([start/2, stop/1]).


start(_StartType, _StartArgs) ->
    pb:create_pool(),
    gen_event:start_link({local, my_event}),
    gen_event:add_handler(my_event, hash_logger, {file,"simple_red.log"}),
    gen_event:add_handler(my_event, hash_logger, standard_io),
    simple_red_sup:start_link().
    


stop(_State) ->
    ok.

