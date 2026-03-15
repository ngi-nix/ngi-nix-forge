module Main.Route exposing (..)

import AppUrl exposing (AppUrl)
import Dict
import List.Extra as List
import Main.Config.App as App


type Route
    = Route_Search String
    | Route_App App.AppName


fromAppUrl : AppUrl -> Maybe Route
fromAppUrl url =
    case url.path of
        [] ->
            Just (Route_Search "")

        [ "app" ] ->
            case url.queryParameters |> Dict.get "q" |> Maybe.andThen List.uncons of
                Nothing ->
                    Nothing

                Just ( q, _ ) ->
                    Just (Route_Search q)

        [ "app", app ] ->
            case app |> App.appName of
                Nothing ->
                    Nothing

                Just name ->
                    Just (Route_App name)

        _ ->
            Nothing


toAppUrl : Route -> AppUrl
toAppUrl route =
    case route of
        Route_Search pattern ->
            case pattern of
                "" ->
                    [ "app" ] |> AppUrl.fromPath

                _ ->
                    { path = [ "app" ]
                    , queryParameters = [ ( "q", [ pattern ] ) ] |> Dict.fromList
                    , fragment = Nothing
                    }

        Route_App name ->
            [ "app", name ] |> AppUrl.fromPath


toString : Route -> String
toString =
    toAppUrl >> AppUrl.toString
