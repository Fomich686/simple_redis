-module(pb).

-export([
          create_pool/0  
        ]).
create_pool()->
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