-module(http_req).

-behaviour(gen_server).

-behaviour(poolboy_worker).

-export([start_link/1]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-export([
        get_http/1,
        get_http_1/1,
        get_http2/0
        ]).

get_http(Id)->
  get_http_1("https://jsonplaceholder.typicode.com/todos/"++integer_to_list(Id)).
get_http2()->
  get_http_1("https://jsonplaceholder.typicode.com/comments").
get_http_1(Http)->
  gen_server:cast(?MODULE, {request, Http}).

start_link(_Args) ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, #{}}.

handle_call(Request, _From, State) ->
    io:format("Request: ~p~n",[Request]),
    {reply, ignored, State}.

handle_cast({request, Http}, State) ->
    % http:request(head, {"https://example.com", []}, [{ssl,[{verify,0}]}], []).
    %gen_event:notify(my_event, Http),
    {ok, RequestId} = httpc:request(get, {Http, []}, [], [{sync, false}]),
    {noreply, State#{RequestId => true}};
handle_cast(Msg, State) ->
    io:format("Msg: ~p~n",[Msg]),  
    {noreply, State}.

handle_info({http,{Ref, Response}}, State) ->
    case maps:is_key(Ref, State) of
      true -> 
              {_,_,Json } = Response,
              Map = jiffy:decode(Json, [return_maps]),
              case is_list(Map) of
                      true -> lists:fold(fun(X,Ac)-> [maps:to_list(X)|Ac] end, [], Map);
                      false ->  Id = maps:get(<<"id">>,Map),
                                Bin_id = integer_to_binary(Id),
                                Hash = <<"id", ":", Bin_id/binary>>,
                                List = maps:fold(fun(K,V,Ac)-> [K,V|Ac] end,[],maps:without([<<"id">>],Map)),
                                %redis_mod:insert_hash(Hash, List),
                                gen_server:call(redis_mod,{insert_hash, Hash,  List}),
                                poolboy:checkin(pool2,self())
              end,
              {noreply, maps:remove(Ref,State)};
      false -> {noreply, State}
    end;
    
handle_info(Info, State)->
    io:format("Info no match: ~p~n",[Info]),  
    {noreply,State}.
terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% jiffy:decode(Msg, [return_maps]),
