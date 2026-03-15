module Main.View exposing (..)

import Dict
import Html exposing (Attribute, Html, a, div, footer, h1, h2, h3, h4, h5, header, hr, input, li, main_, nav, p, section, small, span, text, ul)
import Html.Attributes exposing (class, href, id, name, placeholder, style, tabindex, target, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Main.Config exposing (..)
import Main.Config.App as App exposing (..)
import Main.Model exposing (..)
import Main.Route as Route exposing (..)
import Main.Update exposing (..)
import Markdown


view : Model -> Html Update
view model =
    div
        [ class "min-vh-100 container"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ header [ class "py-3" ] [ viewTitle ]
        , nav [ class "mb-4" ] [ model |> viewSearchInput ]
        , main_ [ class "flex-grow-1" ]
            [ section [] [ model |> viewFocus ] ]
        , footer [ class "mt-auto py-3 border-top" ] [ viewPoweredBy ]
        ]


viewTitle : Html update
viewTitle =
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


viewSearchInput : Model -> Html Update
viewSearchInput model =
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
                , value model.model_search
                , onInput (\search -> Update_Route (Route_Search search))
                ]
                []
            ]
        ]


viewFocus : Model -> Html Update
viewFocus model =
    case model.model_focus of
        ModelFocus_Search ->
            div
                [ class "list-group gap-3"
                , style "flex-wrap" "wrap"
                , style "flex-direction" "row"
                , style "justify-content" "space-between"
                ]
                (model.model_config.config_apps
                    |> Dict.values
                    |> (case model.model_search of
                            "" ->
                                identity

                            _ ->
                                List.filter (\app -> String.contains model.model_search app.app_name)
                       )
                    |> List.map (viewSearchResult model)
                )

        ModelFocus_App state ->
            viewFocus_App state

        ModelFocus_Error { msg } ->
            div [ class "alert alert-danger" ]
                [ text ("Error: " ++ msg) ]


onClickPreventDefault : msg -> Attribute msg
onClickPreventDefault msg =
    Html.Events.preventDefaultOn "click"
        (Decode.succeed ( msg, True ))


viewSearchResult : Model -> App -> Html Update
viewSearchResult model app =
    a
        [ href (Route_App app.app_name |> Route.toString)
        , class "list-group-item list-group-item-action"
        , style "flex-direction" "column"
        , style "align-items" "start"
        , style "flex-shrink" "1"
        , style "flex-grow" "1"
        , style "flex-basis" "20em"
        , onClickPreventDefault (Update_Route (Route_App app.app_name))
        ]
        [ div
            [ name ("app-" ++ app.app_name)
            , class "w-100"
            , style "display" "flex"
            , style "justify-content" "space-between"
            ]
            [ h5 [ class "mb-1" ] [ text app.app_name ]
            , small [] [ text ("v" ++ app.app_version) ]
            ]
        , p
            [ class "mb-1"
            ]
            [ text app.app_description ]
        , p
            [ class "mb-1 "
            ]
            [ small []
                (List.concat
                    [ if app.app_programs.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "programs" ] ]

                      else
                        []
                    , if app.app_container.enable then
                        [ span [ class "badge bg-secondary me-1" ] [ text "container" ] ]

                      else
                        []
                    , if app.app_vm.enable then
                        [ span [ class "badge bg-secondary" ] [ text "oci" ] ]

                      else
                        []
                    ]
                )
            ]
        ]


viewFocus_App : ModelFocusApp -> Html Update
viewFocus_App model =
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
                [ h2 [ style "margin" "0" ] [ text model.modelFocusApp_app.app_name ]
                , text ("v" ++ model.modelFocusApp_app.app_version)
                ]
            , Html.button
                [ class "btn btn-success"
                , onClick (Update_ToggleRunModal True)
                ]
                [ text "Run" ]
            ]
        , div [ class "lead mb-4" ]
            [ text model.modelFocusApp_app.app_description ]
        , viewAppModal model
        ]


viewAppModal : ModelFocusApp -> Html Update
viewAppModal model =
    if not model.modelFocusApp_showRunModal then
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
                            [ h5 [ class "modal-title" ] [ text ("Run " ++ model.modelFocusApp_app.app_name) ]
                            , Html.button
                                [ class "btn-close"
                                , onClick (Update_ToggleRunModal False)
                                ]
                                []
                            ]
                        , div [ class "modal-body" ]
                            [ ul [ class "nav nav-pills mb-4" ]
                                [ viewTab Programs "Programs" model.modelFocusApp_activeModalTab
                                , viewTab Container "Container" model.modelFocusApp_activeModalTab
                                , viewTab VM "VM" model.modelFocusApp_activeModalTab
                                ]
                            , div [ class "tab-content mb-5 p-3 border rounded bg-light" ]
                                [ viewTabContent model.modelFocusApp_activeModalTab ]
                            , hr [] []
                            , div [ id "usage", class "mt-4" ]
                                [ h4 [ class "mb-3" ] [ text "Usage Instructions" ]
                                , div [ class "markdown-content" ]
                                    (Markdown.toHtml Nothing (String.trim model.modelFocusApp_app.app_usage))
                                ]
                            ]
                        ]
                    ]
                ]
            ]


viewTab : ModalTab -> String -> ModalTab -> Html Update
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
            , onClick (Update_SetModalTab targetTab)
            ]
            [ text label ]
        ]


viewTabContent : ModalTab -> Html Update
viewTabContent activeTab =
    case activeTab of
        Programs ->
            div [] [ text "Programs configuration and run commands go here." ]

        Container ->
            div [] [ text "Docker/Podman container run commands go here." ]

        VM ->
            div [] [ text "Virtual Machine configuration goes here." ]


viewPoweredBy : Html update
viewPoweredBy =
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
