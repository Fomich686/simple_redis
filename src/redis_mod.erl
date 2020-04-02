-module(redis_mod).
-behavior(gen_server).

-export([start_link/0]).

-export([
          init/1,
          handle_call/3,
          handle_cast/2,
          handle_info/2,
          terminate/2,
          code_change/3  
        ]).

-export([
          insert_set/2,
          get_set/1,
          insert_hash/2,
          get_hash/1
        ]).

insert_set(Key, Value)->
  gen_server:call(?MODULE,{insert_set, Key, Value}).
get_set(Key)->
  gen_server:call(?MODULE,{get_set, Key}).
insert_hash(Hash, Value)->
  gen_server:call(?MODULE,{insert_hash, Hash,  Value}).
get_hash(Hash)->
  gen_server:call(?MODULE,{get_hash, Hash}).  

start_link()-> 
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([])->
  case eredis:start_link() of
    {ok, Conn} -> {ok, Conn};
    Error -> {error, Error}
  end.
  

handle_call({insert_set, Key, Value}, _From, Conn)->
  Result = case eredis:q(Conn, ["SET", Key, Value]) of
    {ok, <<"OK">>} -> ok;
    _ -> error
   end,
  {reply, Result, Conn};
handle_call({get_set, Key}, _From, Conn)->
  Result = case  eredis:q(Conn, ["GET", Key]) of
            {ok, Resp} -> Resp;
            Error -> Error
           end,
  {reply, Result, Conn};
%
handle_call({insert_hash, Hash,  List}, {From,_}, Conn)->
  Result = case eredis:q(Conn, ["HMSET", Hash | List]) of
              {ok, Resp} -> gen_event:notify(my_event,{msg, Hash, From}),
                            Resp;
              Error -> Error
           end,
  {reply, Result, Conn};

handle_call({get_hash, Key}, _From, Conn)->
  Result = case eredis:q(Conn, ["HGETALL", Key]) of
              {ok, Values} -> Values;
              Error -> Error
           end,
  {reply, Result, Conn};

handle_call(_Request, _From, State)->
  {reply, ignored, State}.
handle_cast(_Requst, State)->
  {noreply, State}.
handle_info(_Info, State)->
  {noreply, State}.
terminate(_Reason, _State)->
  ok.
code_change(_OldVsn, State, _Extra)->
  {ok, State}.