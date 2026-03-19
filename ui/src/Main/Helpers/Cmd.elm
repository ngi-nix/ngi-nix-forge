module Main.Helpers.Cmd exposing (..)


append : Cmd update -> ( a, Cmd update ) -> ( a, Cmd update )
append c ( model, cmd ) =
    ( model, Cmd.batch [ cmd, c ] )


prepend : Cmd update -> ( a, Cmd update ) -> ( a, Cmd update )
prepend c ( model, cmd ) =
    ( model, Cmd.batch [ c, cmd ] )
