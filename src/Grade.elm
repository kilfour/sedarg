module Grade exposing (..)


type Grade
    = APlus
    | A
    | AMinus
    | BPlus
    | B
    | BMinus
    | CPlus
    | C
    | CMinus
    | DPlus
    | D
    | DMinus
    | EPlus
    | E
    | EMinus
    | FPlus
    | F
    | FMinus
    | Undecided


gradeToString : Grade -> String
gradeToString grade =
    case grade of
        APlus ->
            "A+"

        A ->
            "A"

        AMinus ->
            "A-"

        BPlus ->
            "B+"

        B ->
            "B"

        BMinus ->
            "B-"

        CPlus ->
            "C+"

        C ->
            "C"

        CMinus ->
            "C-"

        DPlus ->
            "D+"

        D ->
            "D"

        DMinus ->
            "D-"

        EPlus ->
            "E+"

        E ->
            "E"

        EMinus ->
            "E-"

        FPlus ->
            "F+"

        F ->
            "F"

        FMinus ->
            "F-"

        Undecided ->
            "?"


gradeToControlString : Grade -> String
gradeToControlString grade =
    case grade of
        APlus ->
            "+"

        A ->
            "A"

        AMinus ->
            "-"

        BPlus ->
            "+"

        B ->
            "B"

        BMinus ->
            "-"

        CPlus ->
            "+"

        C ->
            "C"

        CMinus ->
            "-"

        DPlus ->
            "+"

        D ->
            "D"

        DMinus ->
            "-"

        EPlus ->
            "+"

        E ->
            "E"

        EMinus ->
            "-"

        FPlus ->
            "+"

        F ->
            "F"

        FMinus ->
            "-"

        Undecided ->
            "?"


gradeToInt : Grade -> Int
gradeToInt grade =
    case grade of
        APlus ->
            18

        A ->
            17

        AMinus ->
            16

        BPlus ->
            15

        B ->
            14

        BMinus ->
            13

        CPlus ->
            12

        C ->
            11

        CMinus ->
            10

        DPlus ->
            9

        D ->
            8

        DMinus ->
            7

        EPlus ->
            6

        E ->
            5

        EMinus ->
            4

        FPlus ->
            3

        F ->
            2

        FMinus ->
            1

        Undecided ->
            -1


gradeClass : Grade -> String
gradeClass grade =
    case grade of
        APlus ->
            "a plus"

        A ->
            "a"

        AMinus ->
            "a min"

        BPlus ->
            "b plus"

        B ->
            "b"

        BMinus ->
            "b min"

        CPlus ->
            "c plus"

        C ->
            "c"

        CMinus ->
            "c min"

        DPlus ->
            "d plus"

        D ->
            "d"

        DMinus ->
            "d min"

        EPlus ->
            "e plus"

        E ->
            "e"

        EMinus ->
            "e min"

        FPlus ->
            "f plus"

        F ->
            "f"

        FMinus ->
            "f min"

        Undecided ->
            "undecided"


mapAll : (Grade -> a) -> List a
mapAll func =
    [ func FMinus
    , func F
    , func FPlus
    , func EMinus
    , func E
    , func EPlus
    , func DMinus
    , func D
    , func DPlus
    , func CMinus
    , func C
    , func CPlus
    , func BMinus
    , func B
    , func BPlus
    , func AMinus
    , func A
    , func APlus
    , func Undecided
    ]
