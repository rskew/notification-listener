-module(notify_send_server_handler).

-export([init/2]).

init(Req0, State) ->
    #{status := Status, heading := Heading, subheading := Subheading} = cowboy_req:bindings(Req0),
    BgColor = if Status /= <<"0">> -> "-h string:bgcolor:#f00b";
                 true -> "-h string:bgcolor:#0000"
              end,
    Command = ["notify-send -u critical ", BgColor, " ", Heading, " ", Subheading],
    os:cmd(binary_to_list(iolist_to_binary(Command))),
    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/plain">>},
        [<<"Notification ">>, Heading, " ", Subheading, <<" received, status ">>, Status, <<"\n">>],
        Req0),
    {ok, Req, State}.
