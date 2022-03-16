module Diagnostic exposing (main)

import Browser
import Network exposing (addEdge, addNode, node)
import Network.Position exposing (position)
import Problem exposing (Msg, Problem)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as Attribute

main : Program () Problem Msg
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
                , code =
                    { size = 0.1
                    , fill = "black"
                    }
                }
            }

        network =
            Network.empty
                |> addNode (node "A" <| position 0 0)
                |> addNode (node "B" <| position 0.5 0)
                |> addNode (node "Ba" <| position 1 0.5)
                |> addNode (node "Bb" <| position 1 -0.5)
                |> addNode (node "C" <| position -0.5 -1)
                |> addNode (node "D" <| position -0.5 1)
                |> addEdge "AB" "A" "B"
                |> addEdge "AC" "A" "C"
                |> addEdge "AD" "A" "D"
                |> addEdge "BBa" "B" "Ba"
                |> addEdge "BBb" "B" "Bb"

        problem =
            Problem.problem network "A" "AB" "A1b-"
    in
    Browser.element
        { init = \_ -> ( problem, Cmd.none )
        , update = lift Problem.update
        , view = view context >> Svg.toUnstyled
        , subscriptions = \_ -> Sub.none
        }


lift : (msg -> m -> m) -> msg -> m -> ( m, Cmd msg )
lift update msg m =
    ( update msg m, Cmd.none )


view : Problem.Context -> Problem -> Svg Problem.Msg
view context problem =
    let
        offset =
            context.network.node.radius + context.network.node.strokeWidth

        viewBox =
            [ -1 - offset, -1 - offset, 2 + 2 * offset, 2 + 2 * offset ]
                |> List.map String.fromFloat
                |> String.join " "
    in
    Svg.svg
        [ Attribute.width <| String.fromInt context.network.size
        , Attribute.height <| String.fromInt context.network.size
        , Attribute.viewBox viewBox
        , Attribute.cursor "default"
        ]
    <|
        List.concat
            [ Problem.view context problem
            ]
