module Main.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode
import Main.Config.App as App exposing (..)


type alias Config =
    { config_repository : String

    -- Warning(safety): unfortunately, Elm just cannot create a `Dict AppName App`
    -- https://github.com/elm/compiler/blob/master/hints/comparing-custom-types.md#wrapped-types
    , config_apps : Dict String App
    }


configInit : Config
configInit =
    { config_repository = "github:imincik/nix-forge"
    , config_apps = Dict.empty
    }


configDecoder : Decode.Decoder Config
configDecoder =
    Decode.map2 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "apps"
            (Decode.list App.appDecoder
                |> Decode.map (List.map (\app -> ( app.app_name, app )) >> Dict.fromList)
            )
        )
