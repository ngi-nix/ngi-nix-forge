module Main.Helpers.Nix exposing (..)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field, string)


type alias NixUrl =
    String


showNixUrl : NixUrl -> String
showNixUrl url =
    if String.startsWith "github:" url then
        "https://github.com/" ++ String.dropLeft 7 url

    else if String.startsWith "path:" url then
        "#"

    else
        url


showGithubRepoSlug : NixUrl -> String
showGithubRepoSlug url =
    String.dropLeft 7 url


type alias NixName =
    String


type alias NixModuleOptions =
    Dict NixName NixModuleOption


decodeNixModuleOptions : Decoder NixModuleOptions
decodeNixModuleOptions =
    Decode.dict decodeNixModuleOption


type alias NixModuleOption =
    { nixModuleOption_declarations : List String
    , nixModuleOption_description : String
    , nixModuleOption_readOnly : Bool
    , nixModuleOption_type : String
    , nixModuleOption_default : Maybe NixLiteralExpression
    , nixModuleOption_example : Maybe NixLiteralExpression
    }


decodeNixModuleOption : Decoder NixModuleOption
decodeNixModuleOption =
    Decode.map6 NixModuleOption
        (field "declarations" (Decode.list string))
        (field "description" string)
        (field "readOnly" Decode.bool)
        (field "type" string)
        (Decode.maybe (field "default" decodeLiteralExpression))
        (Decode.maybe (field "example" decodeLiteralExpression))


type alias NixLiteralExpression =
    { nixLiteralExpression_type : String
    , nixLiteralExpression_text : String
    }


decodeLiteralExpression : Decoder NixLiteralExpression
decodeLiteralExpression =
    Decode.map2 NixLiteralExpression
        (field "_type" string)
        (field "text" string)
