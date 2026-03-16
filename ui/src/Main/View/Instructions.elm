module Main.View.Instructions exposing (..)

import Html exposing (Html, a, button, code, div, h2, h4, hr, p, pre, text)
import Html.Attributes exposing (class, href, id, style, target)
import Html.Events exposing (onClick)
import Main.Config.App exposing (App)
import Main.Helpers.Format exposing (dedent, format)
import Main.Model exposing (ModalTab(..), ModelFocusApp)
import Markdown.Parser
import Markdown.Renderer exposing (defaultHtmlRenderer)


repositoryToGithubUrl : String -> String
repositoryToGithubUrl repositoryUrl =
    if String.startsWith "github:" repositoryUrl then
        "https://github.com/" ++ String.dropLeft 7 repositoryUrl

    else if String.startsWith "path:" repositoryUrl then
        "#"

    else
        repositoryUrl


codeBlock : (String -> update) -> String -> Html update
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


viewInstructionsNixInstall : (String -> update) -> List (Html update)
viewInstructionsNixInstall onCopy =
    [ h2 [] [ text "QUICK START" ]
    , p [ style "margin-bottom" "0em" ]
        [ text "1. Install Nix "
        , a [ href "https://zero-to-nix.com/start/install", target "_blank" ]
            [ text "(learn more about this installer)." ]
        ]
    , codeBlock onCopy <| """
        curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install

        # to uninstall, run:
        $ /nix/nix-installer uninstall
        """
    , text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) "
    , codeBlock onCopy """export NIX_CONFIG="accept-flake-config = true\""""
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
                                    , codeBlock onCopy <| format (dedent """
                                      nix shell \\
                                        --extra-experimental-features "nix-command flakes" \\
                                        {0}#{1}""") [ repositoryUrl, app.app_name ]
                                    ]

                            else
                                text ""

                        ModalTab_Container ->
                            if app.app_container.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers" ]
                                    , hr [] []
                                    , codeBlock onCopy <|
                                        format (dedent """
                                        nix build \\
                                          --extra-experimental-features "nix-command flakes" \\
                                          {0}#{1}.container && ./result/bin/build-oci

                                        podman load < *.tar

                                        podman-compose --profile services \\
                                          --file $(pwd)/result/compose.yaml up --force-recreate
                                        """) [ repositoryUrl, app.app_name ]
                                    ]

                            else
                                text ""

                        ModalTab_VM ->
                            if app.app_vm.enable then
                                div []
                                    [ p [ style "margin-bottom" "0em" ] [ text "Run application services in Nixos vm" ]
                                    , hr [] []
                                    , codeBlock onCopy <| format (dedent """
                                    nix run \\
                                      --extra-experimental-features "nix-command flakes" \\
                                      {0}#{1}.vm""") [ repositoryUrl, app.app_name ]
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


renderMarkdown : (String -> msg) -> String -> List (Html msg)
renderMarkdown onCopy markdownStr =
    markdownStr
        |> Markdown.Parser.parse
        |> Result.mapError (\_ -> "Failed to parse markdown")
        |> Result.andThen (Markdown.Renderer.render (customRenderer onCopy))
        |> Result.withDefault [ text "Error rendering markdown." ]


customRenderer : (String -> msg) -> Markdown.Renderer.Renderer (Html msg)
customRenderer onCopy =
    { defaultHtmlRenderer
        | codeBlock =
            \block ->
                block.body |> dedent |> codeBlock onCopy
    }


usageInstructions : (String -> msg) -> ModelFocusApp -> Html msg
usageInstructions onCopy model =
    if not (String.isEmpty model.modelFocusApp_app.app_usage) then
        div [ id "usage", class "mt-4" ]
            [ hr [] []
            , h4 [ class "mb-3" ] [ text "Usage Instructions" ]
            , div [ class "markdown-content" ]
                (model.modelFocusApp_app.app_usage
                    |> String.trim
                    |> dedent
                    |> renderMarkdown onCopy
                )
            ]

    else
        text ""
