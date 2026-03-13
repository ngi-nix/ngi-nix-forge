module Main.Select.View exposing (..)

import Dict
import Html exposing (Html, a, div, footer, h2, h3, h4, h5, header, hr, input, li, main_, nav, p, section, small, span, text, ul)
import Html.Attributes exposing (class, href, id, name, placeholder, style, tabindex, target, value)
import Html.Events exposing (onClick, onInput)
import Main.Config exposing (..)
import Main.Config.App as App exposing (..)
import Main.Route as Route exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View.Instructions exposing (..)
import Markdown


viewer : ModelSelect -> Html UpdateSelect
viewer model =
    div
        [ class "min-vh-100 container"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ header [ class "py-3" ] [ viewerTitle ]
        , nav [ class "mb-4" ] [ model |> viewerSearchInput ]
        , main_ [ class "flex-grow-1" ]
            [ section [] [ model |> viewerFocus ] ]
        , footer [ class "mt-auto py-3 border-top" ] [ viewerPoweredBy ]
        ]


viewerTitle : Html msg
viewerTitle =
    h3
        []
        [ a
            [ href "/"
            , style "color" "inherit"
            , style "text-decoration" "none"
            , style "cursor" "pointer"
            ]
            [ text "ngi-nix forge" ]
        ]


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
                    |> List.map (viewerSearchResult model)
                )

        ModelSelectFocus_App state ->
            viewerAppPage state

        ModelSelectFocus_Error { msg } ->
            div [ class "alert alert-danger" ]
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
            , class "w-100"
            , style "display" "flex"
            , style "justify-content" "space-between"
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
                    , if app.container.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "container" ] ]

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


viewerAppModal : { app : App, showRunModal : Bool, activeModalTab : ModalTab } -> Html UpdateSelect
viewerAppModal appState =
    if not appState.showRunModal then
        text ""

    else
        div []
            [ div
                [ class "modal show"
                , style "display" "block"
                , tabindex -1
                , style "background-color" "rgba(0,0,0,0.5)"
                ]
                [ div [ class "modal-dialog modal-lg" ]
                    [ div [ class "modal-content" ]
                        [ div [ class "modal-header bg-light" ]
                            [ h5 [ class "modal-title" ] [ text ("Run " ++ appState.app.name) ]
                            , Html.button
                                [ class "btn-close"
                                , onClick (UpdateSelect_ToggleRunModal False)
                                ]
                                []
                            ]
                        , div [ class "modal-body" ]
                            [ ul [ class "nav nav-pills mb-4" ]
                                [ viewTab Programs "Programs" appState.activeModalTab
                                , viewTab Container "Container" appState.activeModalTab
                                , viewTab VM "VM" appState.activeModalTab
                                ]
                            , div [ class "tab-content mb-5 p-3 border rounded bg-light" ]
                                [ viewTabContent appState.activeModalTab appState.app ]
                            , hr [] []
                            , div [ id "usage", class "mt-4" ]
                                [ h4 [ class "mb-3" ] [ text "Usage Instructions" ]
                                , div [ class "markdown-content" ]
                                    (Markdown.toHtml Nothing (String.trim appState.app.usage))
                                ]
                            ]
                        ]
                    ]
                ]
            ]


viewTab : ModalTab -> String -> ModalTab -> Html UpdateSelect
viewTab targetTab label currentTab =
    let
        activeClass =
            if targetTab == currentTab then
                " active"

            else
                ""
    in
    li [ class "nav-item" ]
        [ Html.button
            [ class ("nav-link" ++ activeClass)
            , style "cursor" "pointer"
            , style "border" "none"
            , onClick (UpdateSelect_SetModalTab targetTab)
            ]
            [ text label ]
        ]


viewTabContent : ModalTab -> App -> Html UpdateSelect
viewTabContent activeTab app =
    case activeTab of
        Programs ->
            div [] [ text "Programs configuration and run commands go here." ]

        Container ->
            div [] [ text "Docker/Podman container run commands go here." ]

        VM ->
            div [] [ text "Virtual Machine configuration goes here." ]


viewerAppPage : { app : App, showRunModal : Bool, activeModalTab : ModalTab } -> Html UpdateSelect
viewerAppPage appState =
    let
        { app } =
            appState
    in
    div []
        [ div
            [ style "display" "flex"
            , style "justify-content" "space-between"
            , style "align-items" "center"
            , style "margin-bottom" "1rem"
            , style "border-bottom" "1px solid #dee2e6"
            , style "padding-bottom" "0.5rem"
            ]
            [ div []
                [ h2 [ style "margin" "0" ] [ text app.name ]
                , text ("v" ++ app.version)
                ]
            , Html.button
                [ class "btn btn-success"
                , onClick (UpdateSelect_ToggleRunModal True)
                ]
                [ text "Run" ]
            ]
        , div [ class "lead mb-4" ]
            [ text app.description ]
        , viewerAppModal appState
        ]



-- footer --


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
