-module(http_req_sync).

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
        get_http/2,
        get_http_1/2,
        get_http2/1
        ]).

get_http(Pid,Id)->
  get_http_1(Pid,"https://jsonplaceholder.typicode.com/todos/"++integer_to_list(Id)).
get_http2(Pid)->
  get_http_1(Pid, "https://jsonplaceholder.typicode.com/comments").
get_http_1(Pid, Http)->
  gen_server:call(Pid, {request, Http}).
start_link(_Args) ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, #{}}.

handle_call({request, Http}, From, State) ->
    % http:request(head, {"https://example.com", []}, [{ssl,[{verify,0}]}], []).
    {ok, {_, _, Response}} = httpc:request(get, {Http, []}, [], [{sync, true}]),
    Map = jiffy:decode(Response, [return_maps]),
              Res = case is_list(Map) of
                      true -> lists:fold(fun(X,Ac)-> [maps:to_list(X)|Ac] end, [], Map);
                      false ->  Id = maps:get(<<"id">>,Map),
                                Bin_id = integer_to_binary(Id),
                                Hash = <<"id", ":", Bin_id/binary>>,
                                List = maps:fold(fun(K,V,Ac)-> [K,V|Ac] end,[],maps:without([<<"id">>],Map)),
                                redis_mod:insert_hash(Hash, List)
                    end,
              io:format("Info: ~p~n",[Res]),
    {reply, Res, State};
handle_call(Request, _From, State) ->
        io:format("Request: ~p~n",[Request]),
        {reply, ignored, State}.
handle_cast(Msg, State) ->
    io:format("Msg: ~p~n",[Msg]),  
    {noreply, State}.

    
handle_info(Info, State)->
    io:format("Info no match: ~p~n",[Info]),  
    {noreply,State}.
terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% jiffy:decode(Msg, [return_maps]),
