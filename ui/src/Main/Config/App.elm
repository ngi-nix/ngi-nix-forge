module Main.Config.App exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode


type alias App =
    { name : AppName
    , description : String
    , version : String
    , usage : String
    , programs : AppPrograms
    , containers : AppContainers
    , oci : Dict String AppOci
    }


type alias AppPrograms =
    { enable : Bool
    }


type alias AppContainers =
    { enable : Bool
    }


type alias AppOci =
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
        (Decode.field "containers" appContainersDecoder)
        (Decode.field "vm" appOciDecoder |> Decode.map (\oci -> [ ( "default", oci ) ] |> Dict.fromList))


appProgramsDecoder : Decode.Decoder AppPrograms
appProgramsDecoder =
    Decode.map AppPrograms
        (Decode.field "enable" Decode.bool)


appContainersDecoder : Decode.Decoder AppContainers
appContainersDecoder =
    Decode.map AppContainers
        (Decode.field "enable" Decode.bool)


appOciDecoder : Decode.Decoder AppOci
appOciDecoder =
    Decode.map AppOci
        (Decode.field "enable" Decode.bool)
