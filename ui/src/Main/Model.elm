module Main.Model exposing (..)

import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Route exposing (..)
import Main.Select.Model exposing (ModelSelect)



-- | Explanation(extensibility):
-- `Model` is a sum-type to support different models
-- though this is no longer used, it may be in a close future,
-- hence keep it a little bit longer until requirements have settled.


type Model
    = Model_Select ModelSelect
