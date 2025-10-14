module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import File exposing (File)
import Grade exposing (Grade)
import Set exposing (Set)
import Url exposing (Url)


type alias Exercise =
    { id : Int
    , title : String
    , link : String
    , children : Exercises
    }


type Exercises
    = Exercises (List Exercise)


type alias Evaluation =
    { clarity : Maybe Grade
    , usefulness : Maybe Grade
    , fun : Maybe Grade
    , theGood : String
    , theBad : String
    , theUgly : String
    }


emptyEvaluation : Evaluation
emptyEvaluation =
    { clarity = Nothing
    , usefulness = Nothing
    , fun = Nothing
    , theGood = ""
    , theBad = ""
    , theUgly = ""
    }


type alias User =
    { name : String
    , pass : String
    , evaluations : Dict Int Evaluation
    }


type alias FrontendModel =
    { key : Key
    , selected : Maybe Exercise
    , expanded : Set Int
    , user : Maybe User
    , pass : String
    }


type alias BackendModel =
    { users : List User
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | LoadFile
    | FileSelected File
    | FileLoaded String
    | StartDownload
    | Login
    | UpdatePass String
    | SelectExercise Int
    | ToggleExpand Int
    | SetClarity Grade
    | SetUsefulness Grade
    | SetFun Grade
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
