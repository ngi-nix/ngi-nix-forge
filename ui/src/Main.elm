module Main exposing (main)

import AppUrl
import Browser
import Main.Config
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Ports.Navigation
import Main.Route exposing (..)
import Main.Update exposing (..)
import Main.View
import Navigation
import Url


main : Program String Model Update
main =
    Browser.element
        { init = init
        , view = Main.View.view
        , update = Main.Update.update
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Update )
init href =
    let
        model =
            { model_config = Main.Config.initConfig
            , model_search = ""
            , model_route = Route_Search ""
            , model_focus = ModelFocus_Error { msg = "Invalid address: " ++ href }
            }
    in
    case href |> Url.fromString of
        Nothing ->
            ( model, Cmd.none )

        Just url ->
            let
                appUrl =
                    url |> AppUrl.fromUrl
            in
            case appUrl |> Main.Route.fromAppUrl of
                Err err ->
                    ( { model | model_focus = ModelFocus_Error { msg = Main.Route.showRouteError err } }
                    , Cmd.none
                    )

                Ok route ->
                    model |> update (Update_Route route)


subscriptions : Model -> Sub Update
subscriptions model =
    let
        activePageSub =
            case model.model_focus of
                ModelFocus_App state ->
                    Main.View.subscriptions state

                _ ->
                    Sub.none

        globalSubs =
            [ Navigation.onEvent Main.Ports.Navigation.onNavEvent Update_Navigation
            ]
    in
    Sub.batch (activePageSub :: globalSubs)
