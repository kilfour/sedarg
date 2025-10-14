module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Evaluation exposing (..)
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


type alias User =
    { name : String
    , pass : String
    , evaluations : Dict Int Evaluation
    }


type alias FrontendModel =
    { key : Key
    , selected : Maybe Exercise
    , expanded : Set Int
    , user : User
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
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


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
