module Main.Helpers.Html exposing (..)

import Html exposing (Attribute, Html, button, code, div, pre, text)
import Html.Attributes exposing (class)
import Html.Events
import Json.Decode


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


{-| `onClick` is like `Html.Events.onClick`
but prevents default action on internal links to avoid full page reloads.

The name conflicts on purpose to prevent accidental use of `Html.Events.onClick`.

Documentation: <https://github.com/mpizenberg/elm-url-navigation-port?tab=readme-ov-file#link-clicks>

-}
onClick : update -> Attribute update
onClick update =
    Html.Events.preventDefaultOn "click"
        (Json.Decode.succeed ( update, True ))
