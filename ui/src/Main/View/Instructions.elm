module Main.View.Instructions exposing (..)

import Html exposing (Html, a, br, button, details, div, h4, hr, li, p, small, summary, text, ul)
import Html.Attributes exposing (class, href, id, style, target)
import Main.Config.App exposing (..)
import Main.Helpers.Html exposing (..)
import Main.Helpers.Markdown as Markdown
import Main.Helpers.Nix exposing (..)
import Main.Model exposing (..)
import Main.Route exposing (..)
import Main.Update exposing (..)


viewInstructionsUsage : Model -> PageApp -> Html Update
viewInstructionsUsage _ pageApp =
    if not (String.isEmpty pageApp.pageApp_app.app_usage) then
        div [ id "usage", class "mt-4" ]
            [ h4 [ class "mb-3" ] [ text "Usage Instructions" ]
            , div [ class "markdown-content" ]
                (pageApp.pageApp_app.app_usage
                    |> Markdown.render
                )
            ]

    else
        text ""


viewInstructionsNixInstall : Model -> PageApp -> Bool -> Html Update
viewInstructionsNixInstall model pageApp flakes =
    div [ class "accordion" ]
        [ details [ class "accordion-item" ]
            [ summary [ class "accordion-button accordion-header fw-bold" ]
                [ text "Install Nix" ]
            , div [ class "accordion-body" ]
                ([ ul
                    [ class "nav nav-underline mb-1"
                    ]
                    [ viewFlakeNavItem model pageApp True
                    , viewFlakeNavItem model pageApp False
                    ]
                 , br [] []
                 , p [ class "mb-1" ]
                    [ text "1. Install Nix "
                    , a [ href "https://github.com/NixOS/nix-installer#nix-installer", target "_blank" ]
                        [ text "(learn more about this installer)." ]
                    ]
                 , codeBlock <|
                    String.join "\n"
                        [ "curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install" ]
                 , small [ class "mb-1" ]
                    [ text "to uninstall, run:" ]
                 , codeBlock <|
                    "/nix/nix-installer uninstall"
                 , p [ class "mt-3 mb-1" ]
                    [ text "2. Accept binaries pre-built by Nix Forge (optional, highly recommended) " ]
                 , codeBlock <|
                    String.join "\n"
                        [ "NL='"
                        , "'"
                        , "export NIX_CONFIG=\"$NIX_CONFIG${NL}accept-flake-config = true\""
                        ]
                 , p [ class "mt-3 mb-1" ]
                    [ text "3. Configure substitutors (optional, highly recommended)" ]
                 , codeBlock <|
                    String.join "\n"
                        [ "export NIX_CONFIG=\"$NIX_CONFIG${NL}\"'substituters = https://cache.nixos.org/ https://ngi.cachix.org/"
                        , "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw='"
                        ]
                 ]
                    ++ (if flakes then
                            [ p [ class "mt-3 mb-1" ]
                                [ text "4. Configure Flakes" ]
                            , codeBlock <|
                                String.join "\n"
                                    [ "export NIX_CONFIG=\"$NIX_CONFIG${NL}\"experimental-features = flakes nix-command"
                                    ]
                            ]

                        else
                            []
                       )
                )
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
                            AppOutput_Shell ->
                                if pageApp.pageApp_app.app_programs.enable then
                                    programsInstructions model pageApp model.model_preferences.pref_flakes

                                else
                                    text ""

                            AppOutput_Container ->
                                if pageApp.pageApp_app.app_container.enable then
                                    div []
                                        [ p [ style "margin-bottom" "0em" ] [ text "Run application services using OCI containers." ]
                                        , br [] []
                                        , codeBlock <|
                                            String.join "\n"
                                                [ String.concat
                                                    [ "nix build "
                                                    , model.model_config.config_repository
                                                    , "#"
                                                    , pageApp.pageApp_app.app_name
                                                    , ".container"
                                                    ]
                                                , "./result/bin/build-oci"
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
                                        , codeBlock <|
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
                        ]
    in
    div []
        [ if not pageApp.pageApp_app.app_programs.enable && not pageApp.pageApp_app.app_container.enable && not pageApp.pageApp_app.app_vm.enable then
            p [ style "color" "red" ] [ text "No output is enabled for this pageApp.pageApp_app.app_ Enable at least one of the - programs, container or nixos vm - in recipe file." ]

          else
            text ""
        , viewInstructionsNixInstall model pageApp model.model_preferences.pref_flakes
        , hr [] []
        , ul
            [ class "nav nav-underline mb-1"
            ]
            [ viewFlakeNavItem model pageApp True
            , viewFlakeNavItem model pageApp False
            ]
        , br [] []
        , instructions
        ]


viewFlakeNavItem : Model -> PageApp -> Bool -> Html Update
viewFlakeNavItem model pageApp isFlakes =
    let
        isActive =
            model.model_preferences.pref_flakes == isFlakes

        btnClasses =
            [ "nav-link"
            , if isActive then
                "active"

              else
                ""
            , if isFlakes then
                "text-primary-emphasis"

              else
                "text-secondary-emphasis"
            ]
                |> String.join " "

        badgeClasses =
            if isActive then
                "badge rounded-pill "
                    ++ (if isFlakes then
                            "text-bg-primary"

                        else
                            "text-bg-secondary"
                       )

            else
                "d-none"
    in
    li [ class "nav-item" ]
        [ button
            [ class btnClasses
            , style "cursor" "pointer"
            , onClick (Update_SetFlakePreference isFlakes)
            ]
            [ text
                (if isFlakes then
                    "Flakes "

                 else
                    "Non-flakes "
                )
            , small [ class badgeClasses ]
                [ text
                    (if isFlakes then
                        "Recommended"

                     else
                        "Legacy"
                    )
                ]
            ]
        ]


programsInstructions : Model -> PageApp -> Bool -> Html Update
programsInstructions model pageApp flakes =
    div []
        ((if flakes then
            [ p [ style "margin-bottom" "0em" ]
                [ text "Create and enter a shell environment for (CLI, GUI) programs." ]
            , br [] []
            ]

          else
            []
         )
            ++ (if not flakes then
                    [ p [ style "margin-bottom" "0em" ]
                        [ text "Build and run the (CLI, GUI) application." ]
                    , br [] []
                    ]

                else
                    []
               )
            ++ [ codeBlock <|
                    String.join "\n" <|
                        if flakes then
                            [ String.concat
                                [ "nix shell "
                                , model.model_config.config_repository
                                , "#"
                                , pageApp.pageApp_app.app_name
                                ]
                            ]

                        else
                            [ String.concat
                                [ "nix-shell \\\n"
                                , "  -I forge=\"https://github.com/ngi-nix/forge/archive/master.tar.gz\" \\\n"
                                , "  -p '(import <forge> {})"
                                , "."
                                , pageApp.pageApp_app.app_name
                                , "' "
                                ]
                            ]
               ]
        )
