module ExerciseList exposing (all, index)

import Dict exposing (Dict)
import Types exposing (Exercise, Exercises(..))


all : Exercises
all =
    Exercises
        [ Exercise 1 "1.Introduction" "1.Introduction/" (Exercises [])
        , Exercise 2 "2.Installation" "2.Installation/" (Exercises [])
        , Exercise 3 "3.BeforeGettingStarted" "3.BeforeGettingStarted/" (Exercises [])
        , Exercise 4 "4.CSharp101" "4.CSharp101/" <|
            Exercises
                [ Exercise 5 "1.Variabelen" "4.CSharp101/1.Variabelen/" (Exercises [])
                , Exercise 6 "2.Operators" "4.CSharp101/2.Operators/" (Exercises [])
                , Exercise 7 "3.Conditions" "4.CSharp101/3.Conditions/" (Exercises [])
                , Exercise 8 "4.Loops" "4.CSharp101/4.Loops/" (Exercises [])
                , Exercise 9 "5.Lists" "4.CSharp101/5.Lists/" (Exercises [])
                , Exercise 10 "6.Strings" "4.CSharp101/6.Strings/" (Exercises [])
                , Exercise 11 "7.Methods" "4.CSharp101/7.Methods/" (Exercises [])
                , Exercise 12 "8.Classes" "4.CSharp101/8.Classes/" (Exercises [])
                , Exercise 13 "9.BringingItAllBackHome" "4.CSharp101/9.BringingItAllBackHome/" (Exercises [])
                , Exercise 14 "10.Exceptions" "4.CSharp101/10.Exceptions/" (Exercises [])
                ]
        , Exercise 15 "5.VCardManager" "5.VCardManager/" (Exercises [])
        , Exercise 16 "6.LegacyLogic" "6.LegacyLogic/" <|
            Exercises
                [ Exercise 17 "1.CalculateIt" "6.LegacyLogic/1.CalculateIt/" (Exercises [])
                ]
        , Exercise 18 "7.TellDontAsk" "7.TellDontAsk/" <|
            Exercises
                [ Exercise 19 "1.WholeValues" "7.TellDontAsk/1.WholeValues/" (Exercises [])
                , Exercise 20 "2.Rooted" "7.TellDontAsk/2.Rooted/" (Exercises [])
                , Exercise 21 "3.EntityLifecycle" "7.TellDontAsk/3.EntityLifecycle/" (Exercises [])
                , Exercise 22 "4.Invariants" "7.TellDontAsk/4.Invariants/" (Exercises [])
                , Exercise 23 "5.GenericIdentity" "7.TellDontAsk/5.GenericIdentity/" (Exercises [])
                , Exercise 24 "6.DTOs" "7.TellDontAsk/6.DTOs/" (Exercises [])
                ]
        , Exercise 25 "8.LinqyBusiness" "8.LinqyBusiness/" <|
            Exercises
                [ Exercise 26 "1.QuerySyntax" "8.LinqyBusiness/1.QuerySyntax/" (Exercises [])
                , Exercise 27 "2.MethodSyntax" "8.LinqyBusiness/2.MethodSyntax/" (Exercises [])
                , Exercise 28 "3.TheRabbitHole" "8.LinqyBusiness/3.TheRabbitHole/" <|
                    Exercises
                        [ Exercise 29 "1.TheBoys" "8.LinqyBusiness/3.TheRabbitHole/1.TheBoys/" (Exercises [])
                        , Exercise 30 "2.HaveAHeart" "8.LinqyBusiness/3.TheRabbitHole/2.HaveAHeart/" (Exercises [])
                        ]
                ]
        , Exercise 31 "9.HorsesForCourses" "9.HorsesForCourses/" <|
            Exercises
                [ Exercise 32 "1.TheStables" "9.HorsesForCourses/1.TheStables/" (Exercises [])
                , Exercise 33 "2.OutOnTheTrack" "9.HorsesForCourses/2.OutOnTheTrack/" (Exercises [])
                , Exercise 34 "3.TheHatPeople" "9.HorsesForCourses/3.TheHatPeople/" (Exercises [])
                , Exercise 35 "4.RespondingToChange" "9.HorsesForCourses/4.RespondingToChange/" (Exercises [])
                ]
        , Exercise 36 "10.MyLittleWebApi" "10.MyLittleWebApi/" (Exercises [])
        , Exercise 37 "11.CommanderData" "11.CommanderData/" <|
            Exercises
                [ Exercise 38 "1.TheSQL" "11.CommanderData/1.TheSQL/" (Exercises [])
                , Exercise 39 "2.EntityFramework" "11.CommanderData/2.EntityFramework/" <|
                    Exercises
                        [ Exercise 40 "1.Preview" "11.CommanderData/2.EntityFramework/1.Preview/" (Exercises [])
                        , Exercise 41 "2.LookingAtTheData" "11.CommanderData/2.EntityFramework/2.LookingAtTheData/" (Exercises [])
                        , Exercise 42 "3.StillExpensiveInnit" "11.CommanderData/2.EntityFramework/3.StillExpensiveInnit/" (Exercises [])
                        , Exercise 43 "4.EvolvingHorses" "11.CommanderData/2.EntityFramework/4.EvolvingHorses/" (Exercises [])
                        , Exercise 44 "5.Paging" "11.CommanderData/2.EntityFramework/5.Paging/" (Exercises [])
                        , Exercise 45 "6.Projections" "11.CommanderData/2.EntityFramework/6.Projections/" (Exercises [])
                        ]
                , Exercise 46 "3.ThisNotesForYou" "11.CommanderData/3.ThisNotesForYou/" (Exercises [])
                ]
        , Exercise 47 "12.InABlazeOrGlory" "12.InABlazeOrGlory/" (Exercises [])
        , Exercise 48 "13.ThisYearsModelVC" "13.ThisYearsModelVC/" <|
            Exercises
                [ Exercise 49 "1.BoltingHourses" "13.ThisYearsModelVC/1.BoltingHourses/" (Exercises [])
                , Exercise 50 "2.Partially" "13.ThisYearsModelVC/2.Partially/" (Exercises [])
                ]
        , Exercise 51 "14.LockTheStableDoors" "14.LockTheStableDoors/" <|
            Exercises
                [ Exercise 52 "1.MVC" "14.LockTheStableDoors/1.MVC/" (Exercises [])
                , Exercise 53 "2.WebApi" "14.LockTheStableDoors/2.WebApi/" (Exercises [])
                ]
        , Exercise 54 "15.AnalyzeThis" "15.AnalyzeThis/" (Exercises [])
        , Exercise 55 "16.SignalR" "16.SignalR/" (Exercises [])
        , Exercise 56 "17.CI-CD" "17.CI-CD/" (Exercises [])
        , Exercise 57 "18.MicroMachines" "18.MicroMachines/" <|
            Exercises
                [ Exercise 58 "1.YACT" "18.MicroMachines/1.YACT/" (Exercises [])
                ]
        , Exercise 59 "19.Mezzanine" "19.Mezzanine/" <|
            Exercises
                [ Exercise 60 "1.LostInTranslation" "19.Mezzanine/1.LostInTranslation/" (Exercises [])
                ]
        , Exercise 61 "20.Katas" "20.Katas/" (Exercises [])
        ]


index : Dict Int Exercise
index =
    let
        flatten (Exercises xs) =
            List.concatMap (\e -> e :: flatten e.children) xs
    in
    flatten all |> List.foldl (\e d -> Dict.insert e.id e d) Dict.empty
