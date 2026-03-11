module Main.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Main.Config.App as App exposing (..)


type alias Config =
    { repositoryUrl : String
    , recipeDirs : RecipeDirs

    -- Warning(safety): unfortunately, Elm just cannot create a `Dict AppName App`
    -- https://github.com/elm/compiler/blob/master/hints/comparing-custom-types.md#wrapped-types
    , apps : Dict String App
    , appsFilter : OptionsFilter
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map4 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "recipeDirs" recipeDirsDecoder)
        (Decode.field "apps" (Decode.list appDecoder |> Decode.map (List.map (\app -> ( app.name, app )) >> Dict.fromList)))
        (Decode.field "appsFilter" optionsFilterDecoder)


type alias OptionsFilter =
    Dict String (List String)


optionsFilterDecoder : Decode.Decoder OptionsFilter
optionsFilterDecoder =
    Decode.dict (Decode.list Decode.string)


type alias RecipeDirs =
    { packages : String
    , apps : String
    }


recipeDirsDecoder : Decode.Decoder RecipeDirs
recipeDirsDecoder =
    Decode.map2 RecipeDirs
        (Decode.field "packages" Decode.string)
        (Decode.field "apps" Decode.string)
