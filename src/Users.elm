module Users exposing (list)

import Dict exposing (Dict)
import Types exposing (..)


list : List User
list =
    let
        buildEvaluations =
            List.range 1 61
                |> List.map (\a -> ( a, emptyEvaluation ))
                |> Dict.fromList
    in
    [ { name = "Abigail"
      , pass = "creative-in-pink"
      , evaluations = buildEvaluations
      }
    , { name = "Alex"
      , pass = "tenacious-poker"
      , evaluations = buildEvaluations
      }
    , { name = "Mathias"
      , pass = "inquisitive-sigh"
      , evaluations = buildEvaluations
      }
    , { name = "Michael"
      , pass = "yes-no-cava"
      , evaluations = buildEvaluations
      }
    , { name = "Naomi"
      , pass = "footless-structure"
      , evaluations = buildEvaluations
      }
    , { name = "Demo"
      , pass = "demo"
      , evaluations = buildEvaluations
      }
    , { name = "Coach"
      , pass = "elmsy"
      , evaluations = Dict.empty
      }
    ]
