-module(edecompiler).

%% API exports
-export([main/1]).

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
-spec main([string()]) -> no_return().
main(BeamFiles) ->
    [case beam_to_erl(BeamFile) of
         ok ->
             ok;
         {error, Reason} ->
             io:format(standard_error, "Failed to decompile ~p for ~p\n", [BeamFile, Reason])
     end || BeamFile <- BeamFiles],
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

-spec beam_to_erl(beam_lib:beam()) -> ok.
beam_to_erl(BeamFile) ->
    case beam_lib:chunks(BeamFile, [abstract_code]) of
        {ok, {_, [{abstract_code, no_abstract_code}]}} ->
            {error, beam_without_debug_info};
        {ok, {_, [{abstract_code, {raw_abstract_v1, Forms}}]}} ->
            Src = erl_prettypr:format(erl_syntax:form_list(tl(Forms))),
            ErlFileName = erl_file_name(BeamFile),
            {ok, Fd} = file:open(ErlFileName, [write]),
            io:fwrite(Fd, "~s~n", [Src]),
            file:close(Fd),
            io:format("Succeed to decompile ~s to ~s\n", [BeamFile, ErlFileName]);
        {error, beam_lib, ErrInfo} ->
            {error, ErrInfo}
    end.

-spec erl_file_name(beam_lib:beam()) -> file:filename_all().
erl_file_name(BeamFile) ->
    BeamFileName = filename:rootname(BeamFile, ".beam"),
    BeamFileName ++ ".erl".
