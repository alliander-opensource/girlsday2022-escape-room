module Diagnostic exposing (main)

import Browser
import Network exposing (addEdge, addNode, node, position)
import Problem


main =
    let
        context =
            { network =
                { size = 1024
                , node =
                    { radius = 0.02
                    , strokeWidth = 0.01
                    , stroke = "black"
                    , fill = "white"
                    }
                , edge =
                    { strokeWidth = 0.015
                    , stroke = "gray"
                    }
                }
            , problem =
                { status =
                    { alive = "green"
                    , dead = "red"
                    , indetermined = "white"
                    }
                }
            }

        network =
            Network.empty
                |> addNode (node "A" <| position 0 0)
                |> addNode (node "B" <| position 1 0)
                |> addNode (node "C" <| position -0.5 -1)
                |> addNode (node "D" <| position -0.5 1)
                |> addEdge "AB" "A" "B"
                |> addEdge "AC" "A" "C"
                |> addEdge "AD" "A" "D"

        problem =
            Problem.problem network "A" "AB"
    in
    Browser.sandbox
        { init = problem
        , update = Problem.update
        , view = Problem.view context
        }
