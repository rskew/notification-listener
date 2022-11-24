-module(notify_send_server_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(PORT, 2001).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([{'_', [{"/:status/:heading/:subheading/", notify_send_server_handler, #{}}]}]),
    {ok, _} = cowboy:start_clear(hello,
        [{port, ?PORT}],
        #{env => #{dispatch => Dispatch}}
    ),
    io:format("Server started on port ~p~n", [?PORT]),
    notify_send_server_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(hello).
