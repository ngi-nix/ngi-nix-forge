module Main.Select.Update exposing (..)

import Dict
import Http
import Main.Clipboard exposing (copyToClipboard)
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Http as Http
import Main.Route exposing (..)
import Main.Select.Model exposing (..)


type UpdateSelect
    = UpdateSelect_App App
    | UpdateSelect_CopyCode String
    | UpdateSelect_GetConfig (Result Http.Error Config)
      -- | Description: an `UpdateSelect` can route
      -- to any other `Route` of the application.
    | UpdateSelect_Route Route
    | UpdateSelect_ToggleRunModal Bool
    | UpdateSelect_SetModalTab ModalTab


updater : UpdateSelect -> ModelSelect -> Updater ModelSelect UpdateSelect
updater msg model =
    case msg of
        UpdateSelect_App app ->
            Updater_Model
                { model
                    | modelSelect_focus =
                        ModelSelectFocus_App
                            { app = app
                            , showRunModal = False
                            , activeModalTab = Programs
                            }
                }

        UpdateSelect_CopyCode code ->
            Updater_Cmd
                ( model, copyToClipboard code )

        UpdateSelect_GetConfig res ->
            case res of
                Ok config ->
                    Updater_Model
                        { model
                            | repositoryUrl = config.repositoryUrl
                            , recipeDirApps = config.recipeDirs.apps
                            , apps = config.apps
                        }

                Err err ->
                    Updater_Model
                        { model | modelSelect_focus = ModelSelectFocus_Error { msg = Http.errorToString err } }

        UpdateSelect_Route route ->
            Updater_Route route

        UpdateSelect_ToggleRunModal visibility ->
            case model.modelSelect_focus of
                ModelSelectFocus_App state ->
                    Updater_Model
                        { model
                            | modelSelect_focus =
                                ModelSelectFocus_App
                                    { state
                                        | showRunModal = visibility
                                    }
                        }

                _ ->
                    Updater_Model model

        UpdateSelect_SetModalTab tab ->
            case model.modelSelect_focus of
                ModelSelectFocus_App state ->
                    Updater_Model
                        { model
                            | modelSelect_focus =
                                ModelSelectFocus_App { state | activeModalTab = tab }
                        }

                _ ->
                    Updater_Model model


router : RouteSelect -> ModelSelect -> Updater ModelSelect UpdateSelect
router rt model =
    case rt of
        RouteSelect_Search search ->
            Updater_Model
                { model
                    | modelSelect_focus = ModelSelectFocus_Search
                    , modelSelect_search = search
                }

        RouteSelect_App appName ->
            Updater_Model
                { model
                    | modelSelect_focus =
                        case model.apps |> Dict.get appName of
                            Just app ->
                                ModelSelectFocus_App
                                    { app = app
                                    , showRunModal = False
                                    , activeModalTab = Programs
                                    }

                            Nothing ->
                                ModelSelectFocus_Error { msg = "No such app: " ++ appName }
                }
