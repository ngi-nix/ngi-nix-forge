module Main.Option exposing (Option, OptionsData, optionsDecoder)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder, field, string)


type alias Option =
    { name : String
    , declarations : List String
    , description : String
    , readOnly : Bool
    , optionType : String
    , default : Maybe LiteralExpression
    , example : Maybe LiteralExpression
    , value : String
    }


type alias LiteralExpression =
    { expressionType : String
    , text : String
    }


type alias OptionsData =
    Dict String Option


literalExpressionDecoder : Decoder LiteralExpression
literalExpressionDecoder =
    Decode.map2 LiteralExpression
        (field "_type" string)
        (field "text" string)


optionDecoder : String -> Decoder Option
optionDecoder name =
    Decode.map8 Option
        (Decode.succeed name)
        (field "declarations" (Decode.list string))
        (field "description" string)
        (field "readOnly" Decode.bool)
        (field "type" string)
        (Decode.maybe (field "default" literalExpressionDecoder))
        (Decode.maybe (field "example" literalExpressionDecoder))
        (Decode.succeed "")


optionsDecoder : Decoder OptionsData
optionsDecoder =
    Decode.keyValuePairs Decode.value
        |> Decode.andThen
            (\pairs ->
                pairs
                    |> List.map (\( key, _ ) -> Decode.field key (optionDecoder key))
                    |> combineDecoders
                    |> Decode.map (List.map2 Tuple.pair (List.map Tuple.first pairs))
                    |> Decode.map Dict.fromList
            )


combineDecoders : List (Decoder a) -> Decoder (List a)
combineDecoders decoders =
    List.foldr
        (Decode.map2 (::))
        (Decode.succeed [])
        decoders
