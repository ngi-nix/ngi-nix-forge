module Main.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import List
import Main.Config.App as Config exposing (..)
import Main.Error exposing (..)
import Main.Helpers.Nix exposing (..)
import Url exposing (Url)


{-| Warning(portability): `Url` only supports HTTP(s) protocol.
-}
type alias UrlHttp =
    Url


type alias Config =
    { config_repository : NixUrl
    , config_recipe : ConfigRecipe
    , config_apps : Dict AppName App
    }


initConfig : Config
initConfig =
    { config_repository = "github:ngi-nix/forge"
    , config_recipe = initRecipe
    , config_apps = Dict.empty
    }


decodeConfig : Decoder Config
decodeConfig =
    Decode.map3 Config
        (Decode.field "repositoryUrl" Decode.string)
        (Decode.field "recipeDirs" decodeConfigRecipe)
        (Decode.field "apps"
            (Decode.list Config.decodeApp
                |> Decode.map (List.map (\app -> ( app.app_name, app )) >> Dict.fromList)
            )
        )


type alias ConfigRecipe =
    { configRecipe_apps : Directory
    , configRecipe_packages : Directory
    }


initRecipe : ConfigRecipe
initRecipe =
    { configRecipe_apps = ""
    , configRecipe_packages = ""
    }


decodeConfigRecipe : Decoder ConfigRecipe
decodeConfigRecipe =
    Decode.map2 ConfigRecipe
        (Decode.field "apps" decodeDirectory)
        (Decode.field "packages" decodeDirectory)


type alias Path =
    String


decodePath : Decoder Path
decodePath =
    Decode.string


type alias Directory =
    Path


decodeDirectory : Decoder Directory
decodeDirectory =
    decodePath
