module Main.View.Instructions exposing (..)

import Html exposing (Html, a, div, h2, h4, hr, p, text)
import Html.Attributes exposing (class, href, id, style, target)
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
    div []
        [ h2 [] [ text "QUICK START" ]
        , p [ style "margin-bottom" "0em" ]
            [ text "1. Install Nix "
            , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
                [ text "(learn more about this installer)." ]
            ]
        , codeBlock Update_CopyCode <|
            String.join "\n"
                [ "curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install"
                , ""
                , "# to uninstall, run:"
                , "$ /nix/nix-installer uninstall"
                ]
        , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
        , codeBlock Update_CopyCode <|
            String.join "\n"
                [ "export NIX_CONFIG='accept-flake-config = true'"
                ]
        , p [ style "margin-bottom" "0em" ] [ text "and select an application to see the usage instructions." ]
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
                                        [ p [ style "margin-bottom" "0em" ] [ text "Create and enter a shell environment for (CLI, GUI) programs." ]
                                        , hr [] []
                                        , codeBlock Update_CopyCode <|
                                            String.join "\n"
                                                [ "nix shell \\"
                                                , "  --extra-experimental-features 'nix-command flakes' \\"
                                                , String.concat
                                                    [ "  "
                                                    , model.model_config.config_repository
                                                    , "#"
                                                    , pageApp.pageApp_app.app_name
                                                    ]
                                                ]
                                        ]

                                else
                                    text ""

                            AppOutput_Container ->
                                if pageApp.pageApp_app.app_container.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers." ]
                                        , hr [] []
                                        , codeBlock Update_CopyCode <|
                                            String.join "\n"
                                                [ "nix build \\"
                                                , "  --extra-experimental-features 'nix-command flakes' \\"
                                                , String.concat
                                                    [ "  "
                                                    , model.model_config.config_repository
                                                    , "#"
                                                    , pageApp.pageApp_app.app_name
                                                    , ".container"
                                                    , " &&"
                                                    ]
                                                , "./result/bin/build-oci"
                                                , ""
                                                , "podman load < *.tar"
                                                , ""
                                                , "podman-compose --profile services \\"
                                                , "  --file $(pwd)/result/compose.yaml up --force-recreate"
                                                ]
                                        ]

                                else
                                    text ""

                            AppOutput_VM ->
                                if pageApp.pageApp_app.app_vm.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Run application services in a NixOS VM." ]
                                        , hr [] []
                                        , codeBlock Update_CopyCode <|
                                            String.join "\n"
                                                [ "nix run \\"
                                                , "  --extra-experimental-features 'nix-command flakes' \\"
                                                , String.concat
                                                    [ "  "
                                                    , model.model_config.config_repository
                                                    , "#"
                                                    , pageApp.pageApp_app.app_name
                                                    , ".vm"
                                                    ]
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
        , instructions
        ]
