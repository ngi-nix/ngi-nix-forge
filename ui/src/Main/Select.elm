module Main.Select exposing (..)

import Browser.Navigation as Nav
import Dict
import Http
import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Select.Model exposing (..)
import Main.Select.Update exposing (..)
import Main.Select.View exposing (..)


init : { navKey : Nav.Key } -> ( ModelSelect, Cmd UpdateSelect )
init { navKey } =
    ( { repositoryUrl = "github:ngi-nix/ngi-nix-forge"
      , recipeDirApps = ""
      , apps = Dict.empty
      , modelSelect_navKey = navKey
      , modelSelect_search = ""
      , modelSelect_focus = ModelSelectFocus_Search
      }
    , httpGetConfig
    )


httpGetConfig : Cmd UpdateSelect
httpGetConfig =
    Http.get
        { url = "/forge-config.json"
        , expect = Http.expectJson UpdateSelect_GetConfig configDecoder
        }
