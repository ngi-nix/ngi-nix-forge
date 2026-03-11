module Main.Format exposing (format)


format : String -> List String -> String
format template replacements =
    let
        replace index replacement result =
            String.replace ("{" ++ String.fromInt index ++ "}") replacement result
    in
    List.indexedMap Tuple.pair replacements
        |> List.foldl (\( i, r ) acc -> replace i r acc) template
