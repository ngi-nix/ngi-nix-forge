module Main.Model exposing (..)

import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Route exposing (..)


type alias Model =
    { model_config : Config
    , model_search : String
    , model_route : Route
    , model_focus : ModelFocus
    }


type ModalTab
    = Programs
    | Container
    | VM


type ModelFocus
    = ModelFocus_App ModelFocusApp
    | ModelFocus_Search
    | ModelFocus_Error { msg : String }


type alias ModelFocusApp =
    { modelFocusApp_app : App
    , modelFocusApp_showRunModal : Bool
    , modelFocusApp_activeModalTab : ModalTab
    }
