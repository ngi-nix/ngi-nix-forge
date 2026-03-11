module Main.Select.View exposing (..)

import Dict
import Html exposing (Html, a, div, footer, h1, h2, h5, header, input, main_, nav, p, section, small, span, text)
import Html.Attributes exposing (class, href, name, placeholder, style, target, value)
import Html.Events exposing (onClick, onInput)
import Main.Config exposing (..)
import Main.Config.App as App exposing (..)
import Main.Route as Route exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View.Instructions exposing (..)


viewer : ModelSelect -> Html UpdateSelect
viewer model =
    div [ class "container" ]
        [ header [] [ viewerTitle ]
        , nav [] [ model |> viewerSearchInput ]
        , main_ []
            [ section [] [ model |> viewerFocus ]
            ]
        , footer [] [ viewerPoweredBy ]
        ]


viewerTitle : Html msg
viewerTitle =
    h1
        []
        [ text "NGI Nix Forge" ]


viewerSearchInput : ModelSelect -> Html UpdateSelect
viewerSearchInput model =
    div
        [ class "name gap-2"
        , style "display" "flex"
        , style "justify-content" "between"
        , style "align-items" "center"
        ]
        [ div [ style "flex-grow" "1" ]
            [ input
                [ class "form-control form-control-lg py-2 my-2"
                , placeholder "Search applications by name"
                , value model.modelSelect_search
                , onInput (\search -> UpdateSelect_Route (Route_Select (RouteSelect_Search search)))
                ]
                []
            ]
        ]


viewerFocus : ModelSelect -> Html UpdateSelect
viewerFocus model =
    case model.modelSelect_focus of
        ModelSelectFocus_Search ->
            div
                [ class "list-group gap-3"
                , style "flex-wrap" "wrap"
                , style "flex-direction" "row"
                , style "justify-content" "space-between"
                ]
                (model.apps
                    |> Dict.values
                    |> (case model.modelSelect_search of
                            "" ->
                                identity

                            _ ->
                                List.filter (\app -> String.contains model.modelSelect_search app.name)
                       )
                    |> List.map (model |> viewerSearchResult)
                )

        ModelSelectFocus_App { app } ->
            div [ class "" ]
                [ h2
                    []
                    [ text app.name
                    ]
                , div
                    []
                    [ text app.version
                    ]
                , div
                    []
                    [ text app.description
                    ]
                , div
                    []
                    [ text app.usage
                    ]
                ]

        ModelSelectFocus_Error { msg } ->
            div []
                [ text ("Error: " ++ msg) ]


viewerSearchResult : ModelSelect -> App -> Html UpdateSelect
viewerSearchResult model app =
    a
        [ href (RouteSelect_App app.name |> Route_Select |> Route.toString)
        , class "list-group-item list-group-item-action"
        , style "flex-direction" "column"
        , style "align-items" "start"
        , style "flex-shrink" "1"
        , style "flex-grow" "1"
        , style "flex-basis" "20em"
        , onClick (UpdateSelect_Route (Route_Select (RouteSelect_App app.name)))
        ]
        [ div
            [ name ("app-" ++ app.name)
            , class "d-flex w-100 justify-content-between"
            ]
            [ h5 [ class "mb-1" ] [ text app.name ]
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


viewerPoweredBy : Html msg
viewerPoweredBy =
    div
        [ class "text-secondary fs-8"
        , style "display" "flex"
        , style "flex-wrap" "wrap"
        , style "flex-direction" "row"
        , style "justify-content" "space-evenly"
        , style "column-gap" "1ex"
        ]
        [ span []
            [ text "Powered by "
            , a [ href "https://nixos.org", target "_blank" ] [ text "Nix" ]
            , text ", "
            , a
                [ href "https://github.com/NixOS/nixpkgs"
                , target "_blank"
                ]
                [ text "Nixpkgs" ]
            , text " and "
            , a [ href "https://elm-lang.org", target "_blank" ] [ text "Elm" ]
            , text ". "
            ]
        , span []
            [ text "Developed by "
            , a
                [ href "https://nixos.org/community/teams/ngi/"
                , target "_blank"
                ]
                [ text "Nix@NGI team." ]
            ]
        , span []
            [ text " Contribute or report issues at "
            , a
                [ href "https://github.com/ngi-nix/ngi-nix-forge"
                , target "_blank"
                ]
                [ text "ngi-nix/ngi-nix-forge" ]
            , text "."
            ]
        ]
