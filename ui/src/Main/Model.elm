module Main.Model exposing (..)

import Main.Config exposing (..)
import Main.Config.App exposing (..)
import Main.Error exposing (..)
import Main.Nix exposing (..)
import Main.Route exposing (..)
import Main.Theme exposing (Theme)


type alias Model =
    { model_config : Config
    , model_search : String
    , model_page : Page
    , model_errors : List Error
    , model_preferences :
        { pref_theme : Theme
        }
    , model_RecipeOptions : ModelRecipeOptions
    }


{-| A `Page` is located at a `Route`,
with more or less data than that `Route`:

  - More data if viewing the `Page` requires more than provided in its address,
    eg. by querying the backend (eg. `pageApp_app`).

  - Less data if navigating away from the `Page` must persist that data,
    and thus be persisted in `Model` (eg. `Route_Search` persists in `model_search`).

-}
type Page
    = Page_Search
    | Page_App PageApp
    | Page_RecipeOptions PageRecipeOptions


type alias PageApp =
    { pageApp_route : RouteApp
    , pageApp_app : App
    }


type alias PageRecipeOptions =
    { pageRecipeOptions_route : RouteRecipeOptions
    }


type alias ModelRecipeOptions =
    { modelRecipeOptions_available : NixModuleOptions
    , modelRecipeOptions_filtered : NixModuleOptions
    }
