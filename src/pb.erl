-module(pb).

-export([
          create_pool/0  
        ]).
create_pool()->
  % PoolArgs = [
  %             {name, {local, pool1}},
  %             {worker_module, worker_demo},
  %             {size, 2}
  %             ],
  % WorkerArgs = [
  %             {config, args}
  %             ], 
  % poolboy:child_spec({local, pool1}, PoolArgs, WorkerArgs).

  poolboy:start(
                [
                  {name, {local, pool1}},
                  {worker_module, worker_demo},
                  {size, 2},
                  {max_overflow, 20}
                ],
                [
                  {config, args}
                ]               
               ),
  poolboy:start(
              [
                {name, {local, pool2}},
                {worker_module, http_req},
                {size, 20},
                {max_overflow, 40}
              ],
              [
                []
              ]               
             ).