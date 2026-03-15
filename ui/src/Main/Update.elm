module Main.Update exposing (..)

import AppUrl exposing (AppUrl)
import Dict
import Http
import Main.Clipboard as Clipboard
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Http as Http
import Main.Model exposing (..)
import Main.Navigation
import Main.Route as Route exposing (..)
import Navigation


type Update
    = Update_CopyCode String
    | Update_GetConfig (Result Http.Error Config)
    | Update_GotNavigationEvent Navigation.Event
    | Update_NavigateTo AppUrl
    | Update_Route Route
    | Update_SetModalTab ModalTab
    | Update_ToggleRunModal Bool


update : Update -> Model -> ( Model, Cmd Update )
update upd model =
    case upd of
        Update_Route route ->
            case route of
                Route_Search search ->
                    ( { model
                        | model_route = route
                        , model_focus = ModelFocus_Search
                        , model_search = search
                      }
                      -- , Navigation.pushUrlWithState Main.Navigation.navCmd
                      --     (Route_ route |> Main.Route.toAppUrl)
                      --     (model.apps |> Json.Encode.dict identity Main.Config.App.appEncoder)
                    , Navigation.pushUrl Main.Navigation.navCmd
                        (route |> Route.toAppUrl)
                    )

                Route_App appName ->
                    ( { model
                        | model_route = route
                        , model_focus =
                            case model.model_config.config_apps |> Dict.get appName of
                                Just app ->
                                    ModelFocus_App
                                        { modelFocusApp_app = app
                                        , modelFocusApp_showRunModal = False
                                        , modelFocusApp_activeModalTab = Programs
                                        }

                                Nothing ->
                                    ModelFocus_Error
                                        { msg =
                                            "No such app: "
                                                ++ appName
                                                ++ ". Available: "
                                                ++ String.concat (model.model_config.config_apps |> Dict.keys)
                                        }
                      }
                    , Cmd.none
                      --, Navigation.pushUrl Main.Navigation.navCmd
                      --    (route |> Route.toAppUrl)
                    )

        Update_GotNavigationEvent event ->
            case event.appUrl |> Route.fromAppUrl of
                Nothing ->
                    ( model, Cmd.none )

                Just route ->
                    ( { model | model_route = route }
                    , Cmd.none
                    )

        Update_NavigateTo url ->
            ( model
            , Navigation.pushUrl Main.Navigation.navCmd url
            )

        Update_CopyCode code ->
            ( model
            , Clipboard.copyToClipboard code
            )

        Update_GetConfig res ->
            case res of
                Ok config ->
                    ( { model | model_config = config }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | model_focus = ModelFocus_Error { msg = Http.errorToString err } }
                    , Cmd.none
                    )

        Update_ToggleRunModal visibility ->
            case model.model_focus of
                ModelFocus_App state ->
                    ( { model
                        | model_focus =
                            ModelFocus_App
                                { state
                                    | modelFocusApp_showRunModal = visibility
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        Update_SetModalTab tab ->
            case model.model_focus of
                ModelFocus_App modelFocusApp ->
                    ( { model
                        | model_focus =
                            ModelFocus_App
                                { modelFocusApp
                                    | modelFocusApp_activeModalTab = tab
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )
