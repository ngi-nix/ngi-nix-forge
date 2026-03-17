module Main.View.Instructions exposing (..)

import Html exposing (Html, a, button, code, div, h2, h4, hr, p, pre, text)
import Html.Attributes exposing (class, href, id, style, target)
import Html.Events exposing (onClick)
import Main.Config.App exposing (App)
import Main.Helpers.Html exposing (..)
import Main.Helpers.Markdown as Markdown
import Main.Model exposing (ModalTab(..), ModelFocusApp)


repositoryToGithubUrl : String -> String
repositoryToGithubUrl repositoryUrl =
    if String.startsWith "github:" repositoryUrl then
        "https://github.com/" ++ String.dropLeft 7 repositoryUrl

    else if String.startsWith "path:" repositoryUrl then
        "#"

    else
        repositoryUrl


viewInstructionsUsage : (String -> update) -> ModelFocusApp -> Html update
viewInstructionsUsage onCopy model =
    if not (String.isEmpty model.modelFocusApp_app.app_usage) then
        div [ id "usage", class "mt-4" ]
            [ hr [] []
            , h4 [ class "mb-3" ] [ text "Usage Instructions" ]
            , div [ class "markdown-content" ]
                (model.modelFocusApp_app.app_usage
                    |> Markdown.render onCopy
                )
            ]

    else
        text ""


viewInstructionsNixInstall : (String -> update) -> List (Html update)
viewInstructionsNixInstall onCopy =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "1. Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)." ]
        ]
    , codeBlock onCopy <|
        String.join "\n"
            [ "curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install"
            , ""
            , "# to uninstall, run:"
            , "$ /nix/nix-installer uninstall"
            ]
    , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
    , codeBlock onCopy <|
        String.join "\n"
            [ "export NIX_CONFIG='accept-flake-config = true'"
            ]
    , p [ style "margin-bottom" "0em" ] [ text "and select an application to see the usage instructions." ]
    ]


viewInstructionsApp : String -> String -> (String -> update) -> Maybe App -> ModalTab -> List (Html update)
viewInstructionsApp repositoryUrl recipeDirApps onCopy maybeApp modalTab =
    case maybeApp of
        Nothing ->
            [ text "No application is selected."
            ]

        Just app ->
            let
                instructions =
                    case modalTab of
                        ModalTab_Programs ->
                            if app.app_programs.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application programs (CLI, GUI) in a shell environment" ]
                                    , hr [] []
                                    , codeBlock onCopy <|
                                        String.join "\n"
                                            [ "nix shell \\"
                                            , "  --extra-experimental-features 'nix-command flakes' \\"
                                            , String.concat
                                                [ "  "
                                                , repositoryUrl
                                                , "#"
                                                , app.app_name
                                                ]
                                            ]
                                    ]

                            else
                                text ""

                        ModalTab_Container ->
                            if app.app_container.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers" ]
                                    , hr [] []
                                    , codeBlock onCopy <|
                                        String.join "\n"
                                            [ "nix build \\"
                                            , "  --extra-experimental-features 'nix-command flakes' \\"
                                            , String.concat
                                                [ "  "
                                                , repositoryUrl
                                                , "#"
                                                , app.app_name
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

                        ModalTab_VM ->
                            if app.app_vm.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services in Nixos vm" ]
                                    , hr [] []
                                    , codeBlock onCopy <|
                                        String.join "\n"
                                            [ "nix run \\"
                                            , "  --extra-experimental-features 'nix-command flakes' \\"
                                            , String.concat
                                                [ "  "
                                                , repositoryUrl
                                                , "#"
                                                , app.app_name
                                                , ".vm"
                                                ]
                                            ]
                                    ]

                            else
                                text ""
            in
            [ if not app.app_programs.enable && not app.app_container.enable && not app.app_vm.enable then
                p [ style "color" "red" ] [ text "No output is enabled for this app.app_ Enable at least one of the - programs, container or nixos vm - in recipe file." ]

              else
                text ""
            , instructions
            , hr [] []
            , text "Recipe: "
            , a
                [ href (repositoryToGithubUrl repositoryUrl ++ "/blob/master/" ++ recipeDirApps ++ "/" ++ app.app_name ++ "/recipe.nix")
                , target "_blank"
                ]
                [ text (recipeDirApps ++ "/" ++ app.app_name ++ "/recipe.nix") ]
            ]
