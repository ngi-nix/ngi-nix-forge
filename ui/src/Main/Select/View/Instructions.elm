module Main.Select.View.Instructions exposing (..)

import Dict
import Html exposing (Html, a, button, code, div, h2, h3, hr, p, pre, span, text)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Main.Config.App exposing (App)
import Main.Format exposing (format)
import Markdown


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
            [ class "btn btn-sm btn-outline-secondary position-absolute top-0 end-0 m-2"
            , onClick (onCopy content)
            ]
            [ text "Copy" ]
        , pre [ class "bg-dark text-warning p-3 rounded border border-secondary" ]
            [ code [] [ text content ] ]
        ]


installNixCmd : String
installNixCmd =
    """curl --proto '=https' --tlsv1.2 -sSf \\
    -L https://install.determinate.systems/nix \\
    | sh -s -- install
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
    format """nix shell {0}#{1}
""" [ repositoryUrl, app.name ]


runAppContainerCmd : String -> App -> String
runAppContainerCmd repositoryUrl app =
    format """nix build {0}#{1}.containers

for image in ./result/*.tar.gz; do
    podman load < $image
done

podman-compose --profile services --file $(pwd)/result/compose.yaml up
""" [ repositoryUrl, app.name ]


runAppVmCmd : String -> App -> String
runAppVmCmd repositoryUrl app =
    format """nix run {0}#{1}.oci
""" [ repositoryUrl, app.name ]


appInstructionsHtml : String -> String -> (String -> msg) -> Maybe App -> List (Html msg)
appInstructionsHtml repositoryUrl recipeDirApps onCopy maybeApp =
    case maybeApp of
        Nothing ->
            [ text "No application is selected."
            ]

        Just app ->
            [ h2 [] [ text app.name ]
            , hr [] []
            , h3 [] [ text "USAGE" ]
            , if not (String.isEmpty app.usage) then
                div []
                    [ Markdown.toHtml [ class "markdown-content" ] (String.trim app.usage)
                    , hr [] []
                    ]

              else
                text ""
            , if not app.programs.enable && not app.containers.enable && not (app.oci |> Dict.values |> List.any (\x -> x.enable)) then
                p [ style "color" "red" ] [ text "No output is enabled for this app. Enable at least one of the - programs, containers or OCI - in recipe file." ]

              else
                text ""
            , if app.programs.enable then
                div []
                    [ p [ style "margin-bottom" "0em" ] [ text "Run application programs (CLI, GUI) in a shell environment" ]
                    , codeBlock onCopy (runAppShellCmd repositoryUrl app)
                    ]

              else
                text ""
            , if app.containers.enable then
                div []
                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services in containers" ]
                    , codeBlock onCopy (runAppContainerCmd repositoryUrl app)
                    ]

              else
                text ""
            , if app.oci |> Dict.values |> List.any (\x -> x.enable) then
                div []
                    (app.oci
                        |> Dict.toList
                        |> List.map
                            (\( n, v ) ->
                                div []
                                    [ p [ style "margin-bottom" "0em" ]
                                        [ text "Run application services in OCI container \"", text n, text "\"" ]
                                    , codeBlock onCopy (runAppVmCmd repositoryUrl app)
                                    ]
                            )
                    )

              else
                text ""
            , hr [] []
            , text "Recipe: "
            , a
                [ href (repositoryToGithubUrl repositoryUrl ++ "/blob/master/" ++ recipeDirApps ++ "/" ++ app.name ++ "/recipe.nix")
                , target "_blank"
                ]
                [ text (recipeDirApps ++ "/" ++ app.name ++ "/recipe.nix") ]
            , a
                [ href "options.html"
                , target "_blank"
                ]
                [ text " (configuration options)" ]
            ]
