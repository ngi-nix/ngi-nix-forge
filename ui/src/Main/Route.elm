module Main.Route exposing (..)

import AppUrl exposing (AppUrl)
import Dict
import Json.Decode
import Json.Encode
import List.Extra as List
import Main.Config.App exposing (..)
import Main.Error exposing (..)
import Main.Nix exposing (..)


{-| Description: a route is an address.
It is visible and usually shareable in the Web browser's URL bar.

Warning(security): it must not contain secret or sensitive data.

-}
type Route
    = Route_Search RouteSearch
    | Route_App RouteApp
    | Route_RecipeOptions RouteRecipeOptions


type alias RouteSearch =
    { routeSearch_pattern : String
    }


type alias RouteApp =
    { -- | Remark(simplicity): this should be `Either` instead of `Result`,
      -- but this requires https://github.com/toastal/either
      routeApp_name : AppName
    , routeApp_runShown : Bool
    , routeApp_runOutput : Maybe AppOutput
    }


type alias RouteRecipeOptions =
    { routeRecipeOptions_pattern : Maybe NixName }


initRouteApp : AppName -> RouteApp
initRouteApp name =
    { routeApp_name = name
    , routeApp_runShown = False
    , routeApp_runOutput = Nothing
    }


{-| BUILD TIME CONFIG:
replaced with deployment root in github workflow script eg. "/forge/"
-}
deployRoot : String
deployRoot =
    ":baseUrl"


deployPath : List String
deployPath =
    deployRoot
        |> String.split "/"
        |> List.filter (\seg -> seg /= "" && seg /= ":" ++ "baseUrl")


fromAppUrl : AppUrl -> Result ErrorRoute Route
fromAppUrl url =
    case url.path |> List.drop (List.length deployPath) of
        [] ->
            Ok (Route_Search { routeSearch_pattern = "" })

        [ "app" ] ->
            case url.queryParameters |> Dict.get "q" |> Maybe.andThen List.uncons of
                Nothing ->
                    Ok (Route_Search { routeSearch_pattern = "" })

                Just ( q, _ ) ->
                    Ok (Route_Search { routeSearch_pattern = q })

        [ "app", app ] ->
            case app |> Json.Encode.string |> Json.Decode.decodeValue Main.Config.App.decodeAppName of
                Err e ->
                    Err (ErrorRoute_Parsing (Json.Decode.errorToString e))

                Ok name ->
                    Ok
                        (Route_App
                            { routeApp_name = name
                            , routeApp_runShown =
                                case url.queryParameters |> Dict.get "showRun" |> Maybe.andThen List.uncons of
                                    Nothing ->
                                        False

                                    Just _ ->
                                        True
                            , routeApp_runOutput =
                                url.queryParameters
                                    |> Dict.get "runOutput"
                                    |> Maybe.andThen List.uncons
                                    |> Maybe.map
                                        (\( output, _ ) ->
                                            case output of
                                                "shell" ->
                                                    AppOutput_Shell

                                                "container" ->
                                                    AppOutput_Container

                                                "vm" ->
                                                    AppOutput_VM

                                                _ ->
                                                    AppOutput_Shell
                                        )
                            }
                        )

        [ "recipe", "options" ] ->
            Ok
                (Route_RecipeOptions
                    { routeRecipeOptions_pattern =
                        url.queryParameters |> Dict.get "q" |> Maybe.andThen List.head
                    }
                )

        _ ->
            Err (ErrorRoute_Unknown url)


toAppUrl : Route -> AppUrl
toAppUrl route =
    case route of
        Route_Search routeSearch ->
            case routeSearch.routeSearch_pattern of
                "" ->
                    { path = deployPath
                    , queryParameters = Dict.empty
                    , fragment = Nothing
                    }

                q ->
                    { path = deployPath ++ [ "app" ]
                    , queryParameters = [ ( "q", [ q ] ) ] |> Dict.fromList
                    , fragment = Nothing
                    }

        Route_App routeApp ->
            { path = deployPath ++ [ "app", routeApp.routeApp_name ]
            , queryParameters =
                [ ( "showRun"
                  , if routeApp.routeApp_runShown then
                        [ "" ]

                    else
                        []
                  )
                , ( "runOutput"
                  , case routeApp.routeApp_runOutput of
                        Nothing ->
                            []

                        Just output ->
                            case output of
                                AppOutput_Shell ->
                                    [ "shell" ]

                                AppOutput_Container ->
                                    [ "container" ]

                                AppOutput_VM ->
                                    [ "vm" ]
                  )
                ]
                    |> Dict.fromList
            , fragment = Nothing
            }

        Route_RecipeOptions routeRecipe ->
            { path = deployPath ++ [ "recipe", "options" ]
            , queryParameters =
                [ ( "q"
                  , case routeRecipe.routeRecipeOptions_pattern of
                        Nothing ->
                            []

                        Just "" ->
                            []

                        Just q ->
                            [ q ]
                  )
                ]
                    |> Dict.fromList
            , fragment = Nothing
            }


toString : Route -> String
toString =
    toAppUrl >> AppUrl.toString
