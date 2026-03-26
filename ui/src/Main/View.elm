module Main.View exposing (..)

import Dict
import Html exposing (Html, a, code, div, footer, h3, h5, header, input, li, main_, nav, p, section, small, span, text, ul)
import Html.Attributes exposing (attribute, class, href, id, name, placeholder, style, tabindex, target, title, type_, value)
import Html.Events exposing (onInput, preventDefaultOn, stopPropagationOn)
import Json.Decode as Decode
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Error
import Main.Helpers.Html exposing (..)
import Main.Helpers.Markdown as Markdown
import Main.Icons exposing (..)
import Main.Model exposing (..)
import Main.Nix exposing (..)
import Main.Route as Route exposing (..)
import Main.Subscriptions exposing (decodeEscapeKey)
import Main.Theme exposing (Theme(..))
import Main.Update exposing (..)
import Main.View.Instructions exposing (..)


view : Model -> Html Update
view model =
    div
        [ class "min-vh-100 container d-flex flex-column"
        ]
        [ header
            [ class "py-3 d-flex align-items-center justify-content-between"
            ]
            [ div
                [ class "d-flex gap-3 flex-grow-1"
                , style "align-items" "center"
                ]
                [ viewTitle
                , model |> viewSearchInput
                ]
            , nav
                [ class "navbar-nav navbar-expand-lg ms-3"
                , class "d-flex ms-3"
                , style "align-items" "center"
                , style "flex-direction" "row"
                , style "justify-content" "space-evenly"
                ]
                [ li [ class "nav-item me-3" ] [ viewRecipeOptionsLink ]
                , model |> viewThemeToggle
                ]
            ]
        , div []
            (model.model_errors
                |> List.map
                    (\error ->
                        div [ class "alert alert-danger" ]
                            [ text ("Error: " ++ Main.Error.showError error) ]
                    )
            )
        , main_
            [ class "flex-grow-1" ]
            [ section [] [ model |> viewPage ] ]
        , footer
            [ class "mt-auto py-3 border-top" ]
            [ viewPoweredBy ]
        ]


viewTitle : Html Update
viewTitle =
    a
        [ href (Route_Search { routeSearch_pattern = "" } |> Route.toString)
        , style "color" "inherit"
        , style "text-decoration" "none"
        , style "cursor" "pointer"
        , class "navbar-brand"
        , style "font-size" "1.5rem"
        , style "font-weight" "bold"
        , onClick (Update_Route (Route_Search { routeSearch_pattern = "" }))
        ]
        [ text "NGI Forge" ]


viewSearchInput : Model -> Html Update
viewSearchInput model =
    div
        [ class "name position-relative flex-grow-1"
        , style "max-width" "600px"
        , style "display" "flex"
        , style "justify-content" "between"
        , style "align-items" "center"
        ]
        [ div
            [ class "position-absolute top-50 start-0 translate-middle-y text-secondary"
            , style "pointer-events" "none"
            , style "margin-left" "1.2rem"
            ]
            [ iconSearch ]
        , input
            [ class "form-control bg-transparent"
            , style "padding-left" "2.5rem"
            , style "padding-top" "0.5rem"
            , style "border-radius" "30px"
            , type_ "search"
            , placeholder <|
                case model.model_page of
                    Page_RecipeOptions _ ->
                        "Search options"

                    _ ->
                        "Search apps"
            , value model.model_search
            , id "main-search-bar"
            , onInput (\s -> Update_SearchInput (UpdateSearchInput_Set s))
            , preventDefaultOn "keydown"
                (decodeEscapeKey
                    |> Decode.map (\_ -> ( Update_SearchInput UpdateSearchInput_PreClear, True ))
                )
            ]
            []
        ]


viewRecipeOptionsLink : Html Update
viewRecipeOptionsLink =
    a
        [ href (Route_RecipeOptions { routeRecipeOptions_pattern = Just "" } |> Route.toString)
        , style "color" "inherit"
        , style "text-decoration" "none"
        , style "cursor" "pointer"
        , class "nav-link"
        , title "View available recipe options"
        , attribute "aria-label" "View available recipe options"
        , onClick (Update_Route (Route_RecipeOptions { routeRecipeOptions_pattern = Just "" }))
        ]
        [ iconBookHalf ]


viewThemeToggle : Model -> Html Update
viewThemeToggle model =
    span
        [ class "nav-item"
        , title "Toggle theme"
        , attribute "aria-label" "Toggle theme"
        , onClick Update_CycleTheme
        ]
        [ case model.model_theme of
            Theme_Dark ->
                iconMoonStarsFill

            Theme_Light ->
                iconSunFill
        ]


viewPage : Model -> Html Update
viewPage model =
    case model.model_page of
        Page_Search ->
            viewPageSearch model

        Page_App pageApp ->
            viewPageApp model pageApp

        Page_RecipeOptions pageRecipeOptions ->
            viewPageRecipeOptions model pageRecipeOptions


viewPageSearch : Model -> Html Update
viewPageSearch model =
    div
        [ class "m-app-grid"
        ]
        (model.model_config.config_apps
            |> Dict.values
            |> (case model.model_search of
                    "" ->
                        identity

                    _ ->
                        List.filter
                            (\app ->
                                let
                                    -- Case Insensitive search
                                    model_search =
                                        String.toLower model.model_search

                                    app_name =
                                        String.toLower app.app_name

                                    app_description =
                                        String.toLower app.app_description

                                    name_matches =
                                        String.contains model_search app_name

                                    desc_matches =
                                        String.contains model_search app_description
                                in
                                name_matches || desc_matches
                            )
               )
            |> List.map (viewPageSearchApp model)
        )


viewPageSearchApp : Model -> App -> Html Update
viewPageSearchApp model app =
    a
        [ href (Route_App (initRouteApp app.app_name) |> Route.toString)
        , class "card m-app-card shadow-sm p-3"
        , style "text-decoration" "none"
        , onClick (Update_Route (Route_App (initRouteApp app.app_name)))
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
                        [ span [ class "badge bg-secondary me-1" ] [ text "shell" ] ]

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


viewPageApp : Model -> PageApp -> Html Update
viewPageApp model pageApp =
    div []
        [ div
            [ style "display" "flex"
            , style "justify-content" "space-between"
            , style "align-items" "center"
            ]
            [ div []
                [ h3 [ style "margin" "0" ]
                    [ text pageApp.pageApp_route.routeApp_name
                    , text " "
                    , small
                        [ class "text-muted"
                        , style "font-size" "0.875rem"
                        ]
                        [ text ("v" ++ pageApp.pageApp_app.app_version) ]
                    ]
                ]
            , Html.button
                [ class "btn btn-success"
                , let
                    route =
                        pageApp.pageApp_route
                  in
                  onClick (Update_Route (Route_App { route | routeApp_runShown = True }))
                ]
                [ text "Run" ]
            ]
        , div
            [ class "mb-4"
            , style "margin-bottom" "1rem"
            , style "border-bottom" "1px solid #dee2e6"
            , style "padding-bottom" "0.5rem"
            ]
            [ text pageApp.pageApp_app.app_description ]
        , viewInstructionsUsage model pageApp
        , viewRecipeLink model pageApp
        , viewPageAppRun model pageApp
        ]


viewRecipeLink : Model -> PageApp -> Html update
viewRecipeLink model pageApp =
    div []
        [ text "Recipe: "
        , a
            [ href
                (String.join "/"
                    [ model.model_config.config_repository |> showNixUrl
                    , "blob/master"
                    , model.model_config.config_recipe.configRecipe_apps
                    , pageApp.pageApp_app.app_name
                    , "recipe.nix"
                    ]
                )
            , target "_blank"
            ]
            [ text (model.model_config.config_recipe.configRecipe_apps ++ "/" ++ pageApp.pageApp_app.app_name ++ "/recipe.nix") ]
        ]


viewPageAppRun : Model -> PageApp -> Html Update
viewPageAppRun model pageApp =
    if not pageApp.pageApp_route.routeApp_runShown then
        text ""

    else
        div []
            [ div
                [ class "modal show"
                , style "display" "block"
                , tabindex -1
                , style "background-color" "rgba(0,0,0,0.5)"
                , let
                    route =
                        pageApp.pageApp_route
                  in
                  onClick (Update_Route (Route_App { route | routeApp_runShown = False }))
                ]
                [ div
                    [ class "modal-dialog modal-lg"
                    , stopPropagationOn "click" (Decode.succeed ( Update_NoOp, True ))
                    ]
                    [ div [ class "modal-content" ]
                        [ div [ class "modal-header" ]
                            [ h5 [ class "modal-title" ] [ text ("Run " ++ pageApp.pageApp_route.routeApp_name) ]
                            , Html.button
                                [ class "btn-close"
                                , let
                                    route =
                                        pageApp.pageApp_route
                                  in
                                  onClick (Update_Route (Route_App { route | routeApp_runShown = False }))
                                ]
                                []
                            ]
                        , div [ class "modal-body" ]
                            [ viewPageAppRunOuputs model pageApp
                            , div [ class "tab-content mb-5 p-3 border rounded" ]
                                [ viewPageAppInstructions model pageApp ]
                            ]
                        ]
                    ]
                ]
            ]


viewPageAppRunOuputs : Model -> PageApp -> Html Update
viewPageAppRunOuputs model pageApp =
    let
        enabled : AppOutput -> Bool
        enabled tab =
            case tab of
                AppOutput_Shell ->
                    pageApp.pageApp_app.app_programs.enable

                AppOutput_Container ->
                    pageApp.pageApp_app.app_container.enable

                AppOutput_VM ->
                    pageApp.pageApp_app.app_vm.enable
    in
    ul [ class "nav nav-pills mb-4" ]
        ([ AppOutput_Shell
         , AppOutput_Container
         , AppOutput_VM
         ]
            |> List.filter enabled
            |> List.map (viewPageAppRunOuput model pageApp)
        )


viewPageAppRunOuput : Model -> PageApp -> AppOutput -> Html Update
viewPageAppRunOuput model pageApp appOutput =
    li [ class "nav-item" ]
        [ Html.button
            [ class
                ([ "nav-link"
                 , if Just appOutput == pageApp.pageApp_route.routeApp_runOutput then
                    "active"

                   else
                    ""
                 ]
                    |> String.join " "
                )
            , style "cursor" "pointer"
            , style "border" "none"
            , let
                route =
                    pageApp.pageApp_route
              in
              onClick (Update_Route (Route_App { route | routeApp_runOutput = Just appOutput }))
            ]
            [ text <| showAppOutput appOutput
            ]
        ]


viewPageRecipeOptions : Model -> PageRecipeOptions -> Html Update
viewPageRecipeOptions model pageRecipeOptions =
    div [ class "list-group" ]
        (model.model_RecipeOptions.modelRecipeOptions_filtered
            |> Dict.toList
            |> List.map (viewPageRecipeOption model pageRecipeOptions)
        )


viewPageRecipeOption : Model -> PageRecipeOptions -> ( NixName, NixModuleOption ) -> Html Update
viewPageRecipeOption model pageRecipeOptions ( optionName, option ) =
    a
        [ class "list-group-item list-group-item-action flex-column align-items-start"
        , href (Route_RecipeOptions { routeRecipeOptions_pattern = Just optionName } |> Route.toString)
        , onClick (Update_Route (Route_RecipeOptions { routeRecipeOptions_pattern = Just optionName }))
        ]
        [ div [ class "d-flex w-100 justify-content-between" ]
            [ h5
                [ class "mb-1"
                ]
                [ code [] [ text optionName ]
                ]
            ]
        , div []
            [ span [ class "fw-bold" ] [ text "Type: " ]
            , code [] [ text option.nixModuleOption_type ]
            ]
        , div []
            [ span [ class "fw-bold" ] [ text "Description: " ]
            , div []
                (option.nixModuleOption_description
                    |> Markdown.render
                )
            ]
        ]


viewPoweredBy : Html update
viewPoweredBy =
    div
        [ class "text-secondary"
        , style "display" "flex"
        , style "flex-wrap" "wrap"
        , style "flex-direction" "row"
        , style "justify-content" "space-evenly"
        , style "column-gap" "1ex"
        , style "font-size" "0.8em"
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
            , text "."
            ]
        , span []
            [ text "Developed by "
            , a
                [ href "https://nixos.org/community/teams/ngi/"
                , target "_blank"
                ]
                [ text "Nix@NGI team" ]
            , text "."
            ]
        , span []
            [ text " Contribute or report issues at "
            , a
                [ href "https://github.com/ngi-nix/forge"
                , target "_blank"
                ]
                [ text "ngi-nix/forge" ]
            , text "."
            ]
        , let
            commit =
                ":master"
          in
          if not (String.contains "master" commit) then
            span []
                [ text " Version "
                , a
                    [ href ("https://github.com/ngi-nix/forge/commit/" ++ commit)
                    , target "_blank"
                    ]
                    [ text commit ]
                , text "."
                ]

          else
            text ""
        ]
