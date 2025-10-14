module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Dict
import Evergreen.V1.Grade
import File
import Set
import Url


type alias Exercise =
    { id : Int
    , title : String
    , link : String
    , children : Exercises
    }


type Exercises
    = Exercises (List Exercise)


type alias Evaluation =
    { clarity : Maybe Evergreen.V1.Grade.Grade
    , usefulness : Maybe Evergreen.V1.Grade.Grade
    , fun : Maybe Evergreen.V1.Grade.Grade
    , theGood : String
    , theBad : String
    , theUgly : String
    }


type alias User =
    { name : String
    , pass : String
    , evaluations : Dict.Dict Int Evaluation
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , selected : Maybe Exercise
    , expanded : Set.Set Int
    , user : Maybe User
    , pass : String
    }


type alias BackendModel =
    { users : List User
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | LoadFile
    | FileSelected File.File
    | FileLoaded String
    | StartDownload
    | Login
    | UpdatePass String
    | SelectExercise Int
    | ToggleExpand Int
    | SetClarity Evergreen.V1.Grade.Grade
    | SetUsefulness Evergreen.V1.Grade.Grade
    | SetFun Evergreen.V1.Grade.Grade
    | EditTheGood String
    | EditTheBad String
    | EditTheUgly String


type ToBackend
    = NoOpToBackend
    | LoggedOn String
    | SaveEvaluation String Int Evaluation
    | GetJsonString
    | UploadData String


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
    | GotUser (Maybe User)
    | Download String
