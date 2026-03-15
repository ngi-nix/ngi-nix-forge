module Main exposing (main)

import AppUrl
import Browser
import Html
import Http
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Navigation
import Main.Route exposing (..)
import Main.Update exposing (..)
import Main.View
import Navigation
import Url


main : Program String Model Update
main =
    Browser.element
        { init = init
        , view = Main.View.view
        , update = Main.Update.update
        , subscriptions = subscriptions
        }


init : String -> ( Model, Cmd Update )
init href =
    ( { model_config = Main.Config.configInit
      , model_search = ""
      , model_route =
            href
                |> Url.fromString
                |> Maybe.andThen (AppUrl.fromUrl >> Main.Route.fromAppUrl)
                |> Maybe.withDefault (Route_Search "")
      , model_focus = ModelFocus_Search
      }
    , cmdGetConfig
    )


cmdGetConfig : Cmd Update
cmdGetConfig =
    Http.get
        { url = "/forge-config.json"
        , expect = Http.expectJson Update_GetConfig configDecoder
        }


subscriptions : Model -> Sub Update
subscriptions _ =
    Navigation.onEvent Main.Navigation.onNavEvent Update_GotNavigationEvent
