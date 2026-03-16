module Main.View exposing (..)

import Browser.Events
import Dict
import Html exposing (Attribute, Html, a, div, footer, h2, h3, h5, header, input, li, main_, nav, p, section, small, span, text, ul)
import Html.Attributes exposing (class, href, name, placeholder, style, tabindex, target, value)
import Html.Events exposing (onClick, onInput, stopPropagationOn)
import Json.Decode as Decode
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Route as Route exposing (..)
import Main.Update exposing (..)
import Main.View.Instructions exposing (usageInstructions, viewInstructionsApp)


view : Model -> Html Update
view model =
    div
        [ class "min-vh-100 container"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ header
            [ class "py-3" ]
            [ viewTitle ]
        , nav
            [ class "mb-4" ]
            [ model |> viewSearchInput ]
        , main_
            [ class "flex-grow-1" ]
            [ section [] [ model |> viewFocus ] ]
        , footer
            [ class "mt-auto py-3 border-top" ]
            [ viewPoweredBy ]
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
                [ class "container m-app-grid"
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
            let
                repositoryUrl =
                    model.model_config.config_repository
            in
            viewFocus_App repositoryUrl state

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
        , class "card m-app-card shadow-sm p-3"
        , style "text-decoration" "none"
        , onClickPreventDefault (Update_Route (Route_App app.app_name))
        ]
        [ div
            [ name ("app-" ++ app.app_name)
            , class "w-100"
            , style "display" "flex"
            , style "justify-content" "space-between"
            ]
            [ h5 [ class "mb-1" ] [ text app.app_name ]
            , small
                [ class "text-muted"
                , style "font-style" "italic"
                ]
                [ text ("v" ++ app.app_version) ]
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
                        [ span [ class "badge bg-secondary me-1" ] [ text "vm" ] ]

                      else
                        []
                    ]
                )
            ]
        ]


viewFocus_App : String -> ModelFocusApp -> Html Update
viewFocus_App repositoryUrl model =
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
                , onClick (Update_SetRunModal True)
                ]
                [ text "Run" ]
            ]
        , div [ class "lead mb-4" ]
            [ text model.modelFocusApp_app.app_description ]
        , viewAppModal repositoryUrl model
        ]


viewAppModal : String -> ModelFocusApp -> Html Update
viewAppModal repositoryUrl model =
    if not model.modelFocusApp_showRunModal then
        text ""

    else
        div []
            [ div
                [ class "modal show"
                , style "display" "block"
                , tabindex -1
                , style "background-color" "rgba(0,0,0,0.5)"
                , onClick (Update_SetRunModal False)
                ]
                [ div
                    [ class "modal-dialog modal-lg"
                    , stopPropagationOn "click" (Decode.succeed ( Update_NoOp, True ))
                    ]
                    [ div [ class "modal-content" ]
                        [ div [ class "modal-header bg-light" ]
                            [ h5 [ class "modal-title" ] [ text ("Run " ++ model.modelFocusApp_app.app_name) ]
                            , Html.button
                                [ class "btn-close"
                                , onClick (Update_SetRunModal False)
                                ]
                                []
                            ]
                        , div [ class "modal-body" ]
                            [ viewModalTabs model
                            , div [ class "tab-content mb-5 p-3 border rounded bg-light" ]
                                [ viewTabContent repositoryUrl model ]
                            , usageInstructions Update_CopyCode model
                            ]
                        ]
                    ]
                ]
            ]


viewTab : ModalTab -> ModelFocusApp -> Html Update
viewTab targetTab model =
    let
        activeClass =
            if targetTab == model.modelFocusApp_activeModalTab then
                " active"

            else
                ""

        targetKey =
            case targetTab of
                ModalTab_Programs ->
                    "programs"

                ModalTab_Container ->
                    "container"

                ModalTab_VM ->
                    "vm"
    in
    li [ class "nav-item" ]
        [ Html.button
            [ class ("nav-link" ++ activeClass)
            , style "cursor" "pointer"
            , style "border" "none"
            , onClick (Update_SetModalTab targetTab)
            ]
            [ text targetKey ]
        ]


viewModalTabs : ModelFocusApp -> Html Update
viewModalTabs model =
    let
        enabled : ModalTab -> Bool
        enabled tab =
            case tab of
                ModalTab_Programs ->
                    model.modelFocusApp_app.app_programs.enable

                ModalTab_Container ->
                    model.modelFocusApp_app.app_container.enable

                ModalTab_VM ->
                    model.modelFocusApp_app.app_vm.enable

        panes =
            [ ModalTab_Programs, ModalTab_Container, ModalTab_VM ]
    in
    ul [ class "nav nav-pills mb-4" ]
        (panes
            |> List.filter enabled
            |> List.map (\tab -> viewTab tab model)
        )


viewTabContent : String -> ModelFocusApp -> Html Update
viewTabContent repositoryUrl model =
    div []
        (viewInstructionsApp
            repositoryUrl
            "recipes/apps"
            Update_CopyCode
            (Just model.modelFocusApp_app)
            model.modelFocusApp_activeModalTab
        )


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


subscriptions : ModelFocusApp -> Sub Update
subscriptions model =
    if model.modelFocusApp_showRunModal then
        Browser.Events.onKeyDown (escapeKeyDecoder |> Decode.map Update_SetRunModal)

    else
        Sub.none


escapeKeyDecoder : Decode.Decoder Bool
escapeKeyDecoder =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\key ->
                if key == "Escape" then
                    Decode.succeed False

                else
                    Decode.fail "Not escape"
            )
