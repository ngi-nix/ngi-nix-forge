module Main.Route exposing (..)

import AppUrl exposing (AppUrl)
import Dict
import List.Extra as List
import Main.Config.App as App


type Updater model cmd
    = Updater_Route Route
    | Updater_Model model
    | Updater_Cmd ( model, Cmd cmd )


type Route
    = Route_Select RouteSelect


type RouteSelect
    = RouteSelect_Search String
    | RouteSelect_App App.AppName


type Slug
    = Slug String


fromAppUrl : AppUrl -> Maybe Route
fromAppUrl url =
    case url.path of
        [] ->
            Just (Route_Select (RouteSelect_Search ""))

        [ "app" ] ->
            case url.queryParameters |> Dict.get "q" |> Maybe.andThen List.uncons of
                Just ( q, _ ) ->
                    Just (Route_Select (RouteSelect_Search q))

                Nothing ->
                    Nothing

        [ "app", app ] ->
            case app |> App.appName of
                Nothing ->
                    Nothing

                Just name ->
                    Just (Route_Select (RouteSelect_App name))

        _ ->
            Nothing


toAppUrl : Route -> AppUrl
toAppUrl page =
    case page of
        Route_Select rt ->
            case rt of
                RouteSelect_Search pattern ->
                    case pattern of
                        "" ->
                            [ "app" ] |> AppUrl.fromPath

                        _ ->
                            { path = [ "app" ]
                            , queryParameters = [ ( "q", [ pattern ] ) ] |> Dict.fromList
                            , fragment = Nothing
                            }

                RouteSelect_App name ->
                    [ "app", name ] |> AppUrl.fromPath


toString : Route -> String
toString =
    toAppUrl >> AppUrl.toString
