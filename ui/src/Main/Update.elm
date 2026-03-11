module Main.Update exposing (..)

import AppUrl
import Browser
import Browser.Navigation as Nav
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Route as Route exposing (..)
import Main.Select exposing (..)
import Main.Select.Model as Select exposing (..)
import Main.Select.Update as Select exposing (..)
import Url


type Update
    = Update_Select UpdateSelect
    | Update_Route Route
    | Update_UrlChange Url.Url
    | Update_LinkClicked Browser.UrlRequest


runUpdater : (model -> Model) -> (update -> Update) -> Model -> Updater model update -> ( Model, Cmd Update )
runUpdater model_ update_ model upd =
    case upd of
        Updater_Cmd ( newModel, newCmd ) ->
            ( model_ newModel, newCmd |> Cmd.map update_ )

        Updater_Model newModel ->
            ( model_ newModel, Cmd.none )

        Updater_Route route_ ->
            model |> update (Update_Route route_)


appendCmd : Cmd cmd -> ( model, Cmd cmd ) -> ( model, Cmd cmd )
appendCmd next ( m, prev ) =
    ( m, [ prev, next ] |> Cmd.batch )


update : Update -> Model -> ( Model, Cmd Update )
update upd model =
    case upd of
        Update_Route route ->
            case route of
                Route_Select routeSelect ->
                    case model of
                        Model_Select modelSelect ->
                            modelSelect
                                |> Select.router routeSelect
                                |> runUpdater Model_Select Update_Select model
                                |> appendCmd (route |> Route.toString |> Nav.pushUrl modelSelect.modelSelect_navKey)

        Update_Select up ->
            case model of
                Model_Select modelSelect ->
                    modelSelect
                        |> Select.updater up
                        |> runUpdater Model_Select Update_Select model

        Update_LinkClicked (Browser.Internal url) ->
            case url |> AppUrl.fromUrl |> Route.fromAppUrl of
                Nothing ->
                    ( model, Cmd.none )

                Just route ->
                    model |> update (Update_Route route)

        _ ->
            ( model, Cmd.none )
