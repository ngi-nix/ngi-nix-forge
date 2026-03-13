module Main.Select.View.Instructions exposing (..)

import Html exposing (Html, a, button, code, div, h2, h3, hr, p, pre, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Main.Config.App exposing (App)
import Main.Format exposing (format)
import Main.Select.Model exposing (ModalTab(..))


repositoryToGithubUrl : String -> String
repositoryToGithubUrl repositoryUrl =
    if String.startsWith "github:" repositoryUrl then
        "https://github.com/" ++ String.dropLeft 7 repositoryUrl

    else if String.startsWith "path:" repositoryUrl then
        "#"

    else
        repositoryUrl


codeBlock : (String -> msg) -> String -> Html msg
codeBlock onCopy content =
    div [ class "position-relative" ]
        [ button
            [ class "btn btn-sm btn-secondary position-absolute top-0 end-0 m-2 button copy"
            , onClick (onCopy content)
            ]
            [ text "" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]


installNixCmd : String
installNixCmd =
    """
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install

# to uninstall, run:
$ /nix/nix-installer uninstall
"""


acceptFlakeConfigCmd : String
acceptFlakeConfigCmd =
    """export NIX_CONFIG="accept-flake-config = true\""""


installInstructionsHtml : (String -> msg) -> List (Html msg)
installInstructionsHtml onCopy =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "1. Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)." ]
        ]
    , codeBlock onCopy installNixCmd
    , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
    , codeBlock onCopy acceptFlakeConfigCmd
    , p [ style "margin-bottom" "0em" ] [ text "and select an application to see the usage instructions." ]
    ]


runAppShellCmd : String -> App -> String
runAppShellCmd repositoryUrl app =
    format """
nix shell {0}#{1}
""" [ repositoryUrl, app.name ]


runAppContainerCmd : String -> App -> String
runAppContainerCmd repositoryUrl app =
    format """
nix build {0}#{1}.container

for image in ./result/*.tar.gz; do
    podman load < $image
done

podman-compose --profile services --file $(pwd)/result/compose.yaml up
""" [ repositoryUrl, app.name ]


runAppVmCmd : String -> App -> String
runAppVmCmd repositoryUrl app =
    format """
nix run {0}#{1}.vm
""" [ repositoryUrl, app.name ]


appInstructionsHtml : String -> String -> (String -> msg) -> Maybe App -> ModalTab -> List (Html msg)
appInstructionsHtml repositoryUrl recipeDirApps onCopy maybeApp modalTab =
    case maybeApp of
        Nothing ->
            [ text "No application is selected."
            ]

        Just app ->
            let
                instructions =
                    case modalTab of
                        Programs ->
                            if app.programs.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application programs (CLI, GUI) in a shell environment" ]
                                    , hr [] []
                                    , codeBlock onCopy (runAppShellCmd repositoryUrl app)
                                    ]

                            else
                                text ""

                        Container ->
                            if app.container.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers" ]
                                    , hr [] []
                                    , codeBlock onCopy (runAppContainerCmd repositoryUrl app)
                                    ]

                            else
                                text ""

                        VM ->
                            if app.vm.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services in Nixos vm" ]
                                    , hr [] []
                                    , codeBlock onCopy (runAppVmCmd repositoryUrl app)
                                    ]

                            else
                                text ""
            in
            [ if not app.programs.enable && not app.container.enable && not app.vm.enable then
                p [ style "color" "red" ] [ text "No output is enabled for this app. Enable at least one of the - programs, container or nixos vm - in recipe file." ]

              else
                text ""
            , instructions
            , hr [] []
            , text "Recipe: "
            , a
                [ href (repositoryToGithubUrl repositoryUrl ++ "/blob/master/" ++ recipeDirApps ++ "/" ++ app.name ++ "/recipe.nix")
                , target "_blank"
                ]
                [ text (recipeDirApps ++ "/" ++ app.name ++ "/recipe.nix") ]
            ]
