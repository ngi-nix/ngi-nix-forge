module Main.Select.View exposing (..)

import Html exposing (Html, div, hr, input, text)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onInput)
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Route exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View.Applications exposing (..)
import Main.Select.View.Instructions exposing (..)


viewer : ModelSelect -> Html UpdateSelect
viewer model =
    div [ class "container" ]
        -- header
        [ div [ class "row" ]
            [ div
                [ class "col-lg-12 border fw-bold fs-1 py-2 my-2"
                ]
                -- header
                [ headerHtml ]
            ]

        -- content
        , div [ class "row" ]
            -- packages panel
            [ div [ class "col-lg border bg-light py-3 my-3" ]
                [ div
                    [ class "name d-flex gap-2 justify-content-between align-items-center"
                    ]
                    [ div [ class "flex-grow-1" ]
                        (viewerSearch model.searchString)
                    ]
                , div
                    [ class "list-group flex-wrap flex-row gap-2 justify-content-between"
                    ]
                    (viewerApps model.apps model.selectedApp model.searchString)

                -- error message
                , case model.error of
                    Just errUpdate ->
                        div [] [ text ("Error: " ++ errUpdate) ]

                    Nothing ->
                        text ""
                ]

            -- instructions panel
            {-
               , div [ class "col-lg-6 bg-dark text-white py-3 my-3" ]
                   [ case ( model.selectedApp ) of
                       (  Nothing ) ->
                           -- install instructions
                           div []
                               (installInstructionsHtml UpdateSelect_CopyCode)

                       _ ->
                           div []
                               (case model.selectedOutput of
                                   OutputCategory_Applications ->
                                       appInstructionsHtml model.repositoryUrl model.recipeDirApps UpdateSelect_CopyCode model.selectedApp
                               )
                   ]
            -}
            ]

        -- footer
        , div [ class "col-sm-12" ]
            [ hr [] []

            -- footer
            , footerHtml
            ]
        ]


viewerSearch : String -> List (Html UpdateSelect)
viewerSearch searchString =
    [ input
        [ class "form-control form-control-lg py-2 my-2"
        , placeholder "Search applications by name"
        , value searchString
        , onInput UpdateSelect_Search
        ]
        []
    ]
