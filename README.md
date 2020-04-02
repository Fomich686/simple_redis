simple_red
=====

An OTP simple CRUD application.
Which loads data from the site JSONPlaceholder and stories it in the Redis.
Requests are sent through file http_req that are running in the poolboy. 

Build
-----

    $ rebar3 compile

Lanch
-----
    $ rebar3 shell
    $ request:gen(3).

The function request:gen(3) gets three json and saves it in Redis.
