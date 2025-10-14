module Evaluation exposing (..)

import Grade exposing (Grade)


type alias Evaluation =
    { clarity : Maybe Grade
    , usefulness : Maybe Grade
    , fun : Maybe Grade
    , theGood : String
    , theBad : String
    , theUgly : String
    }
