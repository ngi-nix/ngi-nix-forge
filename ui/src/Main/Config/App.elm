module Main.Config.App exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


type alias App =
    { app_name : AppName
    , app_description : String
    , app_version : String
    , app_usage : String
    , app_programs : AppPrograms
    , app_container : AppContainer
    , app_vm : AppNixosVm
    }


type alias AppPrograms =
    { enable : Bool
    }


type alias AppContainer =
    { enable : Bool
    }


type alias AppNixosVm =
    { enable : Bool
    }


type alias AppName =
    String


appName : String -> Maybe AppName
appName s =
    if String.all (\c -> 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || '0' <= c && c <= '9' || c == '-') s then
        Just s

    else
        Nothing


appDecoder : Decode.Decoder App
appDecoder =
    Decode.map7 App
        (Decode.field "name" (Decode.map (appName >> Maybe.withDefault "") Decode.string))
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "usage" Decode.string)
        (Decode.field "programs" appProgramsDecoder)
        (Decode.field "container" appContainerDecoder)
        (Decode.field "nixos" appNixosVmDecoder)


appProgramsDecoder : Decode.Decoder AppPrograms
appProgramsDecoder =
    Decode.map AppPrograms
        (Decode.field "enable" Decode.bool)


appContainerDecoder : Decode.Decoder AppContainer
appContainerDecoder =
    Decode.map AppContainer
        (Decode.field "enable" Decode.bool)


appNixosVmDecoder : Decode.Decoder AppNixosVm
appNixosVmDecoder =
    Decode.map AppNixosVm
        (Decode.field "enable" Decode.bool)
