%%% Copyright (C) 2005-2008 Wager Labs, SA

-module(pp).

-export([old_write/1, old_read/1]).

-export([read/1, write/1, test/0]).

-include("test.hrl").
-include("common.hrl").
-include("pp.hrl").
-include("schema.hrl").

-import(pickle, [pickle/2, unpickle/2, byte/0, 
                 short/0, sshort/0, int/0, sint/0, 
                 long/0, slong/0, list/2, choice/2, 
                 optional/1, wrap/2, tuple/1, record/2, 
                 binary/1, string/0, wstring/0
                ]).

-define(PP_VER, 1).

old_write(Data) ->
    term_to_binary(Data).

old_read(Bin) when is_binary(Bin) ->
    binary_to_term(Bin).

nick() ->
    string().

pass() ->
    string().

message() ->
    string().

location() ->
    string().

game_type() ->
    byte().

expected_players() ->
    int().

joined_players() ->
    int().

waiting_players() ->
    int().

player_timeout() ->
    int().

start_delay() ->
    int().

total_inplay() ->
    int().

total_amount() ->
    int().

call_amount() ->
    int().

raise_min() ->
    int().

raise_max() ->
    int().

stage() ->
    byte().

button() ->
    byte().

sb() ->
    byte().

bb() ->
    byte().

cards() ->
    list(byte(), card()).

card() ->
    record(card, {
             byte(),
             byte()
            }).

hand() ->
    record(hand, {
             combo(),
             card(), 
             card()
            }).

combo() ->
    byte().

limit_type() ->
    byte().

limit() ->
    record(limit, {
             limit_type(),
             int(),
             int()
            }).

query_op() ->
    record(query_op, {
             byte(),
             byte()
            }).

game_to_id(Game) ->
    cardgame:call(Game, 'ID').
    
id_to_game(GID) ->
    case db:find_game(GID) of
        Pid when is_pid(Pid) ->
            Pid;
        Any ->
            Any
    end.
    
game() ->
    wrap({fun game_to_id/1, fun id_to_game/1}, int()).
         
player_to_id(Player) ->
    gen_server:call(Player, 'ID').
    
id_to_player(PID) ->
    case mnesia:dirty_read(tab_player, PID) of
        [Player] ->
            Player#tab_player.process;
        Any ->
            Any
    end.
    
player() ->
    wrap({fun player_to_id/1, fun id_to_player/1}, int()).

amount() ->
    int().

seat_num() ->
    byte().

state() ->
    byte().

%% Does not get written, is set to none on read

internal() -> 
    {fun(Acc, _) -> Acc end, 
     fun(Bin) -> {none, Bin} end}.
    
%%% Commands 

bad() ->
    record(bad, {
             byte(),
             byte()
            }).

good() ->
    record(good, {
             byte(),
             byte()
            }).

login() ->
    record(login, {
             nick(),
             pass()
            }).

logout() ->
    record(logout, {
            }).

watch() ->
    record(watch, {
             game(),
             player()
            }).

unwatch() ->
    record(unwatch, {
             game(),
             player()
            }).

wait_bb() ->
    record(wait_bb, {
             game(), 
             player(),
             internal()
            }).

call() ->
    record(call, {
             game(),
             player(),
             amount(),
             internal(),
             internal()
            }).

raise() ->
    record(raise, {
             game(),
             player(),
             raise(),
             total_amount(), % notification only
             internal(),
             internal(),
             internal(),
             internal()
            }).

fold() ->
    record(fold, {
             game(),
             player()
            }).

join() ->
    record(join, {
             game(),
             player(),
             seat_num(),
             amount(),
             internal(),
             internal(),
             internal()
            }).

leave() ->
    record(leave, {
             game(),
             player(),
             internal(),
             internal()
            }).

sit_out() ->
    record(sit_out, {
             game(),
             player(),
             internal()
            }).

come_back() ->
    record(come_back, {
             game(),
             player(),
             internal()
            }).

chat() ->
    record(chat, {
             game(),
             player(),
             message(),
             internal()
            }).

game_query() ->
    record(game_query, {
             game_type(),
             limit_type(),
             query_op(), % query op
             query_op(), % query op
             query_op()
            }).

seat_query() ->
    record(seat_query, {
             game()
            }).

player_query() ->
    record(player_query, {
             player()
            }).

balance_query() ->
    record(balance_query, {
            }).

dynamic_start_game() ->
    record(dynamic_start_game, {
             game_type(),
             expected_players(),
             limit()
            }).

test_start_game() ->
    record(test_start_game, {
             game_type(),
             expected_players(),
             limit(),
             start_delay(),
             player_timeout(),
             cards()
            }).

game_info() ->
    record(game_info, {
             game(),
             game_type(),
             limit(),
             expected_players(),
             joined_players(),
             waiting_players()
            }).

player_info() ->
    record(player_info, {
             player(),
             total_inplay(), 
             nick(),
             location()
            }).

bet_req() ->
    record(bet_req, {
             game(),
             player(),
             call_amount(),
             raise_min(),
             raise_max()
            }).

notify_draw() ->
    record(notify_draw, {
             game(), 
             player(),
             card()
            }).

notify_shared() ->
    record(notify_shared, {
             game(),
             card()
            }).

notify_start_game() ->
    record(notify_start_game, {
             game(),
             button(),
             sb(), 
             bb()
            }).

notify_button() ->
    record(notify_button, {
             game(),
             button()
            }).

notify_sb() ->
    record(notify_sb, {
             game(),
             sb()
            }).

notify_bb() ->
    record(notify_bb, {
             game(),
             bb()
            }).

notify_end_game() ->
    record(notify_end_game, {
             game()
            }).

notify_cancel_game() ->
    record(notify_cancel_game, {
             game()
            }).

notify_win() ->
    record(notify_win, {
             game(),
             player(),
             amount()
            }).

notify_my_hand() ->
    record(notify_my_hand, {
             game(),
             player(),
             hand()
            }).

notify_muck() ->
    record(notify_muck, {
             game(),
             player(),
             hand()
            }).

notify_quit() ->
    record(notify_quit, {
             player()
            }).

game_stage() ->
    record(game_stage, {
             game(),
             stage()
            }).

seat_state() ->
    record(seat_state, {
             game(), 
             seat_num(),
             state(),
             player(),
             amount()
            }).

you_are() ->
    record(you_are, {
             player()
            }).

goto() ->
    record(goto, {
             host, 
             port
            }).

balance() ->
    record(balance, {
             amount(),
             amount()
            }).

game_inplay() ->
    record(game_inplay, {
             game(), 
             player(),
             seat_num(),
             amount()
            }).

ping() ->
    record(ping, {
            }).

pong() ->
    record(pong, {
            }).

%%% Pickle

write(R) when is_record(R, bad) ->
    [?CMD_BAD|pickle(bad(), R)];

write(R) when is_record(R, good) ->
    [?CMD_GOOD|pickle(good(), R)];

write(R) when is_record(R, login) ->
    [?CMD_LOGIN|pickle(login(), R)];

write(R) when is_record(R, logout) ->
    [?CMD_LOGOUT|pickle(logout(), R)];

write(R) when is_record(R, watch) ->
    [?CMD_WATCH|pickle(watch(), R)];

write(R) when is_record(R, unwatch) ->
    [?CMD_UNWATCH|pickle(unwatch(), R)];

write(R) when is_record(R, wait_bb) ->
    [?CMD_WAIT_BB|pickle(wait_bb(), R)];

write(R) when is_record(R, call) ->
    [?CMD_CALL|pickle(call(), R)];

write(R) when is_record(R, raise) ->
    [?CMD_RAISE|pickle(raise(), R)];

write(R) when is_record(R, fold) ->
    [?CMD_FOLD|pickle(fold(), R)];

write(R) when is_record(R, join) ->
    [?CMD_JOIN|pickle(join(), R)];

write(R) when is_record(R, leave) ->
    [?CMD_LEAVE|pickle(leave(), R)];

write(R) when is_record(R, sit_out) ->
    [?CMD_SIT_OUT|pickle(sit_out(), R)];

write(R) when is_record(R, come_back) ->
    [?CMD_COME_BACK|pickle(come_back(), R)];

write(R) when is_record(R, chat) ->
    [?CMD_CHAT|pickle(chat(), R)];

write(R) when is_record(R, game_query) ->
    [?CMD_GAME_QUERY|pickle(game_query(), R)];

write(R) when is_record(R, seat_query) ->
    [?CMD_SEAT_QUERY|pickle(seat_query(), R)];

write(R) when is_record(R, player_query) ->
    [?CMD_PLAYER_QUERY|pickle(player_query(), R)];

write(R) when is_record(R, balance_query) ->
    [?CMD_BALANCE_QUERY|pickle(balance_query(), R)];

write(R) when is_record(R, dynamic_start_game) ->
    [?CMD_DYNAMIC_START_GAME|pickle(dynamic_start_game(), R)];

write(R) when is_record(R, test_start_game) ->
    [?CMD_TEST_START_GAME|pickle(test_start_game(), R)];

write(R) when is_record(R, game_info) ->
    [?CMD_GAME_INFO|pickle(game_info(), R)];

write(R) when is_record(R, player_info) ->
    [?CMD_PLAYER_INFO|pickle(player_info(), R)];

write(R) when is_record(R, bet_req) ->
    [?CMD_BET_REQ|pickle(bet_req(), R)];

write(R) when is_record(R, notify_draw) ->
    [?CMD_NOTIFY_DRAW|pickle(notify_draw(), R)];

write(R) when is_record(R, notify_shared) ->
    [?CMD_NOTIFY_SHARED|pickle(notify_shared(), R)];

write(R) when is_record(R, notify_start_game) ->
    [?CMD_NOTIFY_START_GAME|pickle(notify_start_game(), R)];

write(R) when is_record(R, notify_end_game) ->
    [?CMD_NOTIFY_END_GAME|pickle(notify_end_game(), R)];

write(R) when is_record(R, notify_cancel_game) ->
    [?CMD_NOTIFY_CANCEL_GAME|pickle(notify_cancel_game(), R)];

write(R) when is_record(R, notify_win) ->
    [?CMD_NOTIFY_WIN|pickle(notify_win(), R)];

write(R) when is_record(R, notify_my_hand) ->
    [?CMD_NOTIFY_MY_HAND|pickle(notify_my_hand(), R)];

write(R) when is_record(R, notify_muck) ->
    [?CMD_NOTIFY_MUCK|pickle(notify_muck(), R)];

write(R) when is_record(R, notify_quit) ->
    [?CMD_NOTIFY_QUIT|pickle(notify_quit(), R)];

write(R) when is_record(R, game_stage) ->
    [?CMD_GAME_STAGE|pickle(game_stage(), R)];

write(R) when is_record(R, seat_state) ->
    [?CMD_SEAT_STATE|pickle(seat_state(), R)];

write(R) when is_record(R, you_are) ->
    [?CMD_YOU_ARE|pickle(you_are(), R)];

write(R) when is_record(R, goto) ->
    [?CMD_GOTO|pickle(goto(), R)];

write(R) when is_record(R, balance) ->
    [?CMD_BALANCE|pickle(balance(), R)];

write(R) when is_record(R, game_inplay) ->
    [?CMD_GAME_INPLAY|pickle(game_inplay(), R)];

write(R) when is_record(R, notify_button) ->
    [?CMD_NOTIFY_BUTTON|pickle(notify_button(), R)];

write(R) when is_record(R, notify_sb) ->
    [?CMD_NOTIFY_SB|pickle(notify_sb(), R)];

write(R) when is_record(R, notify_bb) ->
    [?CMD_NOTIFY_BB|pickle(notify_bb(), R)];

write(R) when is_record(R, ping) ->
    [?CMD_PING|pickle(ping(), R)];

write(R) when is_record(R, pong) ->
    [?CMD_PONG|pickle(pong(), R)].


%%% Unpickle

read(<<?CMD_BAD, Bin/binary>>) ->
    unpickle(bad(), Bin);

read(<<?CMD_GOOD, Bin/binary>>) ->
    unpickle(good(), Bin);

read(<<?CMD_LOGIN, Bin/binary>>) ->
    unpickle(login(), Bin);

read(<<?CMD_LOGOUT, Bin/binary>>) ->
    unpickle(logout(), Bin);

read(<<?CMD_WATCH, Bin/binary>>) ->
    unpickle(watch(), Bin);

read(<<?CMD_UNWATCH, Bin/binary>>) ->
    unpickle(unwatch(), Bin);

read(<<?CMD_WAIT_BB, Bin/binary>>) ->
    unpickle(wait_bb(), Bin);

read(<<?CMD_CALL, Bin/binary>>) ->
    unpickle(call(), Bin);

read(<<?CMD_RAISE, Bin/binary>>) ->
    unpickle(raise(), Bin);

read(<<?CMD_FOLD, Bin/binary>>) ->
    unpickle(fold(), Bin);

read(<<?CMD_JOIN, Bin/binary>>) ->
    unpickle(join(), Bin);

read(<<?CMD_LEAVE, Bin/binary>>) ->
    unpickle(leave(), Bin);

read(<<?CMD_SIT_OUT, Bin/binary>>) ->
    unpickle(sit_out(), Bin);

read(<<?CMD_COME_BACK, Bin/binary>>) ->
    unpickle(come_back(), Bin);

read(<<?CMD_CHAT, Bin/binary>>) ->
    unpickle(chat(), Bin);

read(<<?CMD_GAME_QUERY, Bin/binary>>) ->
    unpickle(game_query(), Bin);

read(<<?CMD_SEAT_QUERY, Bin/binary>>) ->
    unpickle(seat_query(), Bin);

read(<<?CMD_PLAYER_QUERY, Bin/binary>>) ->
    unpickle(player_query(), Bin);

read(<<?CMD_BALANCE_QUERY, Bin/binary>>) ->
    unpickle(balance_query(), Bin);

read(<<?CMD_DYNAMIC_START_GAME, Bin/binary>>) ->
    unpickle(dynamic_start_game(), Bin);

read(<<?CMD_TEST_START_GAME, Bin/binary>>) ->
    unpickle(test_start_game(), Bin);

read(<<?CMD_GAME_INFO, Bin/binary>>) ->
    unpickle(game_info(), Bin);

read(<<?CMD_PLAYER_INFO, Bin/binary>>) ->
    unpickle(player_info(), Bin);

read(<<?CMD_BET_REQ, Bin/binary>>) ->
    unpickle(bet_req(), Bin);

read(<<?CMD_NOTIFY_DRAW, Bin/binary>>) ->
    unpickle(notify_draw(), Bin);

read(<<?CMD_NOTIFY_SHARED, Bin/binary>>) ->
    unpickle(notify_shared(), Bin);

read(<<?CMD_NOTIFY_START_GAME, Bin/binary>>) ->
    unpickle(notify_start_game(), Bin);

read(<<?CMD_NOTIFY_END_GAME, Bin/binary>>) ->
    unpickle(notify_end_game(), Bin);

read(<<?CMD_NOTIFY_CANCEL_GAME, Bin/binary>>) ->
    unpickle(notify_cancel_game(), Bin);

read(<<?CMD_NOTIFY_WIN, Bin/binary>>) ->
    unpickle(notify_win(), Bin);

read(<<?CMD_NOTIFY_MY_HAND, Bin/binary>>) ->
    unpickle(notify_my_hand(), Bin);

read(<<?CMD_NOTIFY_MUCK, Bin/binary>>) ->
    unpickle(notify_muck(), Bin);

read(<<?CMD_NOTIFY_QUIT, Bin/binary>>) ->
    unpickle(notify_quit(), Bin);

read(<<?CMD_GAME_STAGE, Bin/binary>>) ->
    unpickle(game_stage(), Bin);

read(<<?CMD_SEAT_STATE, Bin/binary>>) ->
    unpickle(seat_state(), Bin);

read(<<?CMD_YOU_ARE, Bin/binary>>) ->
    unpickle(you_are(), Bin);

read(<<?CMD_GOTO, Bin/binary>>) ->
    unpickle(goto(), Bin);

read(<<?CMD_BALANCE, Bin/binary>>) ->
    unpickle(balance(), Bin);

read(<<?CMD_GAME_INPLAY, Bin/binary>>) ->
    unpickle(game_inplay(), Bin);

read(<<?CMD_NOTIFY_BUTTON, Bin/binary>>) ->
    unpickle(notify_button(), Bin);

read(<<?CMD_NOTIFY_SB, Bin/binary>>) ->
    unpickle(notify_sb(), Bin);

read(<<?CMD_NOTIFY_BB, Bin/binary>>) ->
    unpickle(notify_bb(), Bin);

read(<<?CMD_PING, Bin/binary>>) ->
    unpickle(ping(), Bin);

read(<<?CMD_PONG, Bin/binary>>) ->
    unpickle(pong(), Bin).

test() ->
    ok.
