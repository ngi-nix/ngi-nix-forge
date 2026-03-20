module Main.View.Instructions exposing (..)

import Html exposing (Html, a, br, details, div, h2, h4, hr, li, p, small, summary, text, ul)
import Html.Attributes exposing (attribute, class, href, id, style, target)
import Main.Config.App exposing (..)
import Main.Helpers.Html exposing (..)
import Main.Helpers.Markdown as Markdown
import Main.Model exposing (..)
import Main.Route exposing (..)
import Main.Update exposing (..)


viewInstructionsUsage : Model -> PageApp -> Html Update
viewInstructionsUsage model pageApp =
    if not (String.isEmpty pageApp.pageApp_app.app_usage) then
        div [ id "usage", class "mt-4" ]
            [ hr [] []
            , h4 [ class "mb-3" ] [ text "Usage Instructions" ]
            , div [ class "markdown-content" ]
                (pageApp.pageApp_app.app_usage
                    |> Markdown.render Update_CopyCode
                )
            ]

    else
        text ""


viewInstructionsNixInstall : Model -> Html Update
viewInstructionsNixInstall _ =
    div [ class "accordion" ]
        [ details [ class "accordion-item", attribute "open" "" ]
            [ summary [ class "accordion-button accordion-header fw-bold" ]
                [ text "Prerequisites" ]
            , div [ class "accordion-body" ]
                [ p [ class "mb-1" ]
                    [ text "1. Install Nix "
                    , a [ href "https://github.com/NixOS/nix-installer#nix-installer", target "_blank" ]
                        [ text "(learn more about this installer)." ]
                    ]
                , codeBlock Update_CopyCode <|
                    String.join "\n"
                        [ "curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install" ]
                , small [ class "mb-1" ]
                    [ text "to uninstall, run:" ]
                , codeBlock Update_CopyCode <|
                    "/nix/nix-installer uninstall"
                , p [ class "mt-3 mb-1" ]
                    [ text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) " ]
                , codeBlock Update_CopyCode <|
                    String.join "\n"
                        [ "export NIX_CONFIG='accept-flake-config = true'" ]
                , p [ class "mt-3 mb-1" ]
                    [ text "3. Configure substitutors (optional, highly recommended)" ]
                , codeBlock Update_CopyCode <|
                    String.join "\n"
                        [ "export NIX_CONFIG='substituters = https://cache.nixos.org/ https://ngi.cachix.org/"
                        , "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw='"
                        ]
                ]
            ]
        ]


viewPageAppInstructions : Model -> PageApp -> Html Update
viewPageAppInstructions model pageApp =
    let
        instructions =
            case pageApp.pageApp_route.routeApp_runOutput of
                Nothing ->
                    text "There is no such output for this application"

                Just output ->
                    div []
                        [ case output of
                            AppOutput_Programs ->
                                if pageApp.pageApp_app.app_programs.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Enter a shell environment with CLI and GUI programs." ]
                                        , br [] []
                                        , codeBlock Update_CopyCode <|
                                            String.concat
                                                [ "nix shell "
                                                , model.model_config.config_repository
                                                , "#"
                                                , pageApp.pageApp_app.app_name
                                                ]
                                        ]

                                else
                                    text ""

                            AppOutput_Container ->
                                if pageApp.pageApp_app.app_container.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers." ]
                                        , br [] []
                                        , codeBlock Update_CopyCode <|
                                            String.join "\n"
                                                [ String.concat
                                                    [ "nix run "
                                                    , model.model_config.config_repository
                                                    , "#"
                                                    , pageApp.pageApp_app.app_name
                                                    , ".container"
                                                    ]
                                                , ""
                                                , "podman load < *.tar"
                                                , ""
                                                , "podman-compose --profile services --file $(pwd)/result/compose.yaml up"
                                                ]
                                        ]

                                else
                                    text ""

                            AppOutput_VM ->
                                if pageApp.pageApp_app.app_vm.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Run application services in a NixOS VM." ]
                                        , br [] []
                                        , codeBlock Update_CopyCode <|
                                            String.concat
                                                [ "nix run "
                                                , model.model_config.config_repository
                                                , "#"
                                                , pageApp.pageApp_app.app_name
                                                , ".vm"
                                                ]
                                        ]

                                else
                                    text ""
                        , viewInstructionsUsage model pageApp
                        ]
    in
    div []
        [ if not pageApp.pageApp_app.app_programs.enable && not pageApp.pageApp_app.app_container.enable && not pageApp.pageApp_app.app_vm.enable then
            p [ style "color" "red" ] [ text "No output is enabled for this pageApp.pageApp_app.app_ Enable at least one of the - programs, container or nixos vm - in recipe file." ]

          else
            text ""
        , viewInstructionsNixInstall model
        , hr [ ] [ ]
        , instructions
        ]
