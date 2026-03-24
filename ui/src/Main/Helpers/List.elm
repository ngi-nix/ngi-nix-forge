module Main.Helpers.List exposing (..)

{-| @'chunksOf' n@ splits a list into length-n pieces. The last
piece will be shorter if @n@ does not evenly divide the length of
the list. If @n <= 0@, @'chunksOf' n l@ returns an infinite list
of empty lists.

AdaptedFrom: <https://hackage.haskell.org/package/split/docs/Data-List-Split.html#v:chunksOf>

-}


chunksOf : Int -> List a -> List (List a)
chunksOf n xs =
    case xs of
        [] ->
            []

        _ ->
            let
                ( ys, zs ) =
                    splitAt n xs
            in
            ys :: chunksOf n zs


{-| 'splitAt' @n xs@ returns a tuple where first element is @xs@ prefix of
length @n@ and second element is the remainder of the list.

AdaptedFrom: <https://hackage-content.haskell.org/package/base-4.22.0.0/docs/Prelude.html#v:splitAt>

-}
splitAt : Int -> List a -> ( List a, List a )
splitAt n ls =
    if n <= 0 then
        ( [], ls )

    else
        splitAtUnsafe n ls


splitAtUnsafe : Int -> List a -> ( List a, List a )
splitAtUnsafe n xxs =
    case ( n, xxs ) of
        ( _, [] ) ->
            ( [], [] )

        ( 1, x :: xs ) ->
            ( [ x ], xs )

        ( m, x :: xs ) ->
            let
                ( xs2, xs3 ) =
                    splitAtUnsafe (m - 1) xs
            in
            ( x :: xs2, xs3 )


{-| List index (subscript) operator, starting from 0.

Warning(performance): This function takes linear time in the index.

-}
at : Int -> List a -> Maybe a
at n xs =
    if n < 0 then
        Nothing

    else
        xs |> List.drop n |> List.head
