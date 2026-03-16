module Main.Update exposing (..)

import Dict
import Http
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Helpers.Http as Http
import Main.Model exposing (..)
import Main.Ports.Clipboard as Clipboard
import Main.Ports.Navigation
import Main.Route as Route exposing (..)
import Navigation


type alias Updater =
    Model -> ( Model, Cmd Update )


type Update
    = Update_Chain (List Update)
    | Update_CopyCode String
    | Update_Config (Result Http.Error Config)
    | Update_Navigation Navigation.Event
    | Update_Route Route
    | Update_SetModalTab ModalTab
    | Update_SetRunModal Bool
    | Update_Updater Updater
    | Update_NoOp


update : Update -> Updater
update upd model =
    case upd of
        Update_Chain ups ->
            let
                chain msg1 ( model1, cmds1 ) =
                    let
                        ( model2, cmds2 ) =
                            update msg1 model1
                    in
                    ( model2, Cmd.batch [ cmds1, cmds2 ] )
            in
            ups |> List.foldl chain ( model, Cmd.none )

        Update_Navigation event ->
            case event.appUrl |> Route.fromAppUrl of
                Err err ->
                    ( { model | model_focus = ModelFocus_Error { msg = Route.showRouteError err } }
                    , Cmd.none
                    )

                Ok route ->
                    model |> updateConfig (updateRoute route)

        Update_Route route ->
            ( model
            , Navigation.pushUrl Main.Ports.Navigation.navCmd (route |> Route.toAppUrl)
            )

        Update_CopyCode code ->
            ( model
            , Clipboard.copyToClipboard code
            )

        Update_Config res ->
            case res of
                Ok config ->
                    ( { model | model_config = config }
                    , Cmd.none
                    )

                Err err ->
                    ( { model | model_focus = ModelFocus_Error { msg = Http.errorToString err } }
                    , Cmd.none
                    )

        Update_SetRunModal visibility ->
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

        Update_NoOp ->
            ( model, Cmd.none )

        Update_Updater up ->
            model |> up


updateRoute : Route -> Updater
updateRoute route model =
    case route of
        Route_Search search ->
            ( { model
                | model_route = route
                , model_focus = ModelFocus_Search
                , model_search = search
              }
            , Cmd.none
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
                                , modelFocusApp_activeModalTab = ModalTab_Programs
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
            )


{-| `updateConfig up` populate `model_config` if empty, then run `up`.
`up` is thus always run after `model_config` has been updated.
-}
updateConfig : Updater -> Updater
updateConfig up model =
    if Dict.isEmpty model.model_config.config_apps then
        ( model
        , Http.get
            { url = "/forge-config.json"
            , expect = Http.expectJson (\res -> Update_Chain [ Update_Config res, Update_Updater up ]) Main.Config.decodeConfig
            }
        )

    else
        model |> up
