module Main.Select exposing (..)

import Dict
import Http
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View exposing (..)


init : () -> ( ModelSelect, Cmd UpdateSelect )
init _ =
    ( { repositoryUrl = "github:imincik/nix-forge"
      , recipeDirApps = ""
      , apps = Dict.empty
      , selectedApp = Nothing
      , searchString = ""
      , error = Nothing
      }
    , httpGetConfig
    )


httpGetConfig : Cmd UpdateSelect
httpGetConfig =
    Http.get
        { url = "/forge-config.json"
        , expect = Http.expectJson UpdateSelect_GetConfig configDecoder
        }
