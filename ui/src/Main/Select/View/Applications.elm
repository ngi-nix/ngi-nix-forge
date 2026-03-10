module Main.Select.View.Applications exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, a, div, h5, p, small, span, text)
import Html.Attributes exposing (class, href, name, style)
import Html.Events exposing (onClick)
import Main.Config exposing (..)
import Main.Config.App as App exposing (..)
import Main.Route exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View.Instructions exposing (..)


viewerApps : Dict String App -> Maybe App -> String -> List (Html UpdateSelect)
viewerApps apps selectedApp filter =
    apps
        |> Dict.filter (\name app -> String.contains filter name)
        |> Dict.values
        |> List.map (\app -> viewerApp app selectedApp)


viewerApp : App -> Maybe App -> Html UpdateSelect
viewerApp app selectedApp =
    a
        [ href ("/app/" ++ App.unAppName app.name)
        , class
            ("list-group-item list-group-item-action flex-column align-items-start" ++ appActiveState app selectedApp)
        , style "width" "49%"
        , onClick (UpdateSelect_Route (Route_Select (RouteSelect_App app.name)))
        ]
        [ div
            [ name ("app-" ++ App.unAppName app.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text (App.unAppName app.name) ]
            , small [] [ text ("v" ++ app.version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text app.description ]
        , p
            [ class "mb-1 "
            ]
            [ small []
                (List.concat
                    [ if app.programs.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "programs" ] ]

                      else
                        []
                    , if app.containers.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "containers" ] ]

                      else
                        []
                    , if app.oci |> Dict.values |> List.any (\x -> x.enable) then
                        [ span [ class "badge bg-secondary" ] [ text "oci" ] ]

                      else
                        []
                    ]
                )
            ]
        ]


appActiveState : App -> Maybe App -> String
appActiveState app selectedApp =
    case selectedApp of
        Just sel ->
            if app.name == sel.name then
                "active"

            else
                "inactive"

        Nothing ->
            "inactive"
