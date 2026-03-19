module Main exposing (main)

import AppUrl
import Browser
import Dict
import Json.Encode
import Main.Config
import Main.Config.App exposing (..)
import Main.Model exposing (..)
import Main.Route exposing (..)
import Main.Subscriptions
import Main.Theme exposing (themeFromString)
import Main.Update exposing (..)
import Main.View
import Url


type alias Flags =
    { href : String
    , theme : String
    }


main : Program Flags Model Update
main =
    Browser.element
        { init = init
        , view = Main.View.view
        , update = Main.Update.update
        , subscriptions = Main.Subscriptions.subscriptions
        }


init : Flags -> ( Model, Cmd Update )
init flags =
    let
        model =
            { model_config = Main.Config.initConfig
            , model_search = ""
            , model_page = Page_Search
            , model_errors = []
            , model_theme = themeFromString flags.theme
            , model_RecipeOptions =
                { modelRecipeOptions_available = Dict.empty
                , modelRecipeOptions_filtered = Dict.empty
                }
            }
    in
    case flags.href |> Url.fromString of
        Nothing ->
            ( model, Cmd.none )

        Just url ->
            model
                |> update
                    (Update_Navigation
                        { appUrl = url |> AppUrl.fromUrl
                        , state = Json.Encode.null
                        }
                    )
