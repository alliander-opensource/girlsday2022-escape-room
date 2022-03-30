module Diagnostic exposing (main)

import Browser
import Network exposing (EdgeId, Network, addEdge, addNode, node)
import Network.Position exposing (position)
import Problem exposing (Context, Problem)
import Random
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as Attribute


main : Program () Model Msg
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
                , delay = 1000
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

        cmd =
            Network.randomEdge network
                |> Random.generate Broken
    in
    Browser.element
        { init = \_ -> ( Initializing context network, cmd )
        , update = update
        , view = view >> Svg.toUnstyled
        , subscriptions = \_ -> Sub.none
        }


type Model
    = Initializing Context Network
    | Initialized Context Problem
    | Failed


type Msg
    = ProblemMsg Problem.Msg
    | Broken (Maybe EdgeId)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ProblemMsg m, Initialized context problem ) ->
            let
                ( p, cmd ) =
                    Problem.update context m problem
            in
            ( Initialized context p, Cmd.map ProblemMsg cmd )

        ( Broken (Just e), Initializing context network ) ->
            let
                problem =
                    Problem.problem network "A" e "A1b-"
            in
            ( Initialized context problem, Cmd.none )

        ( Broken Nothing, Initializing _ _ ) ->
            ( Failed, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Svg Msg
view model =
    case model of
        Initializing _ network ->
            viewInitializing network

        Initialized context problem ->
            viewInitialized context problem

        Failed ->
            viewFailed


viewInitializing : Network -> Svg Msg
viewInitializing _ =
    Svg.svg [] []


viewInitialized : Context -> Problem -> Svg Msg
viewInitialized context problem =
    let
        offset =
            context.network.node.radius + context.network.node.strokeWidth

        viewBox =
            [ -1 - offset, -1 - offset, 2 + 2 * offset, 2 + 2 * offset ]
                |> List.map String.fromFloat
                |> String.join " "

        cursor =
            if Problem.isDetermining problem then
                "wait"

            else
                "default"
    in
    Svg.map ProblemMsg <|
        Svg.svg
            [ Attribute.width <| String.fromInt context.network.size
            , Attribute.height <| String.fromInt context.network.size
            , Attribute.viewBox viewBox
            , Attribute.cursor cursor
            ]
        <|
            List.concat
                [ Problem.view context problem
                ]


viewFailed : Svg Msg
viewFailed =
    Svg.svg []
        [ Svg.text_ [ Attribute.x "0", Attribute.y "0" ] [ Svg.text "Could not generate a broken edge" ]
        ]
