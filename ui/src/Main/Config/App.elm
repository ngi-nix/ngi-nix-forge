module Main.Config.App exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias App =
    { app_name : AppName
    , app_description : String
    , app_version : String
    , app_usage : String
    , app_shell : AppShell
    , app_container : AppContainer
    , app_vm : AppNixosVm
    }


type alias AppShell =
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


decodeApp : Decoder App
decodeApp =
    Decode.map7 App
        (Decode.field "name" decodeAppName)
        (Decode.field "description" Decode.string)
        (Decode.field "version" Decode.string)
        (Decode.field "usage" Decode.string)
        (Decode.field "shell" decodeAppShell)
        (Decode.field "container" decodeAppContainer)
        (Decode.field "nixos" decodeAppNixosVm)


decodeAppName : Decoder AppName
decodeAppName =
    Decode.string
        |> Decode.andThen
            (\s ->
                if String.length s > 0 && String.all (\c -> 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || '0' <= c && c <= '9' || c == '-' || c == '_') s then
                    Decode.succeed s

                else
                    Decode.fail <| "Invalid application name: " ++ s
            )


decodeAppShell : Decoder AppShell
decodeAppShell =
    Decode.map AppShell
        (Decode.field "enable" Decode.bool)


decodeAppContainer : Decoder AppContainer
decodeAppContainer =
    Decode.map AppContainer
        (Decode.field "enable" Decode.bool)


decodeAppNixosVm : Decoder AppNixosVm
decodeAppNixosVm =
    Decode.map AppNixosVm
        (Decode.field "enable" Decode.bool)


type AppOutput
    = AppOutput_Shell
    | AppOutput_Container
    | AppOutput_VM


showAppOutput : AppOutput -> String
showAppOutput r =
    case r of
        AppOutput_Shell ->
            "Shell"

        AppOutput_Container ->
            "Container"

        AppOutput_VM ->
            "VM"
