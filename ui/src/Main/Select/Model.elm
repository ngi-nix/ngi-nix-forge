module Main.Select.Model exposing (..)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Main.Config exposing (..)
import Main.Config.App exposing (..)


type alias ModelSelect =
    { repositoryUrl : String
    , recipeDirApps : String
    , apps : Dict String App
    , modelSelect_navKey : Nav.Key
    , modelSelect_search : String
    , modelSelect_focus : ModelSelectFocus
    }


type ModalTab
    = Programs
    | Containers
    | VM


type ModelSelectFocus
    = ModelSelectFocus_App
        { app : App
        , showRunModal : Bool
        , activeModalTab : ModalTab
        }
    | ModelSelectFocus_Search
    | ModelSelectFocus_Error { msg : String }
