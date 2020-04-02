%%%-------------------------------------------------------------------
%% @doc simple_red top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(simple_red_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).


start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 10, period => 60},
    ChildSpec =[
                #{
                  id => redis_mod, 
                  start => {redis_mod, start_link, []},
                  restart => permanent,
                  type => worker,
                  shutdown => 100
                }
              %  ,
              %   #{
              %     id => http_req,
              %     start => {http_req, start_link, []},
              %     restart => permanent,
              %     type => worker,
              %     shutdown => 100
              %   }
                ],
    {ok, { SupFlags, ChildSpec} }.
