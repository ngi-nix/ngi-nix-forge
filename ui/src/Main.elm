module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Route exposing (..)
import Main.Select as Select exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View as Select exposing (..)
import Main.Update exposing (..)
import Url exposing (Url)


main : Program () Model Update
main =
    Browser.application
        { init = init
        , view = \model -> { title = "NGI Nix Forge", body = [ view model ] }
        , update = Main.Update.update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = Update_LinkClicked
        , onUrlChange = Update_UrlChange
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Update )
init inp url navKey =
    let
        ( modelSelect, cmdSelect ) =
            Select.init { navKey = navKey }
    in
    ( Model_Select modelSelect
    , Cmd.batch
        [ cmdSelect |> Cmd.map Update_Select
        ]
    )


view : Model -> Html Update
view model =
    case model of
        Model_Select m ->
            m |> Select.viewer |> Html.map Update_Select
