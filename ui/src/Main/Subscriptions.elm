module Main.Subscriptions exposing (..)

import Browser.Events
import Json.Decode as Decode
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Ports.Navigation
import Main.Route exposing (..)
import Main.Update exposing (..)
import Navigation


subscriptions : Model -> Sub Update
subscriptions model =
    Sub.batch
        [ Navigation.onEvent Main.Ports.Navigation.onNavEvent Update_Navigation
        , case model.model_page of
            Page_App pageApp ->
                if pageApp.pageApp_route.routeApp_runShown then
                    Sub.none

                else
                    Browser.Events.onKeyDown decodeAmbientKeyPress

            _ ->
                Browser.Events.onKeyDown decodeAmbientKeyPress
        , case model.model_page of
            Page_App pageApp ->
                if pageApp.pageApp_route.routeApp_runShown then
                    Browser.Events.onKeyDown
                        (decodeEscapeKey
                            |> Decode.map
                                (\showRun ->
                                    let
                                        route =
                                            pageApp.pageApp_route
                                    in
                                    Update_Route (Route_App { route | routeApp_runShown = showRun })
                                )
                        )

                else
                    Sub.none

            _ ->
                Sub.none
        ]


decodeEscapeKey : Decode.Decoder Bool
decodeEscapeKey =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\key ->
                if key == "Escape" then
                    Decode.succeed False

                else
                    Decode.fail "Not escape"
            )


decodeAmbientKeyPress : Decode.Decoder Update
decodeAmbientKeyPress =
    Decode.map3
        (\key node modifier ->
            Update_AmbientKeyPress
                { key = key
                , focusedTyping =
                    List.member node
                        -- When typing into some actual input fields
                        [ "INPUT"
                        , "TEXTAREA"
                        , "SELECT"
                        ]
                , hasModifier = modifier
                }
        )
        (Decode.field "key" Decode.string)
        (Decode.at [ "target", "nodeName" ] Decode.string)
        (Decode.oneOf
            [ Decode.field "ctrlKey" Decode.bool
            , Decode.field "metaKey" Decode.bool
            ]
        )
