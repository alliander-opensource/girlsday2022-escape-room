module Diagnostic exposing (main)

import Browser
import Code exposing (Code)
import Network exposing (EdgeId, Network, NodeId, addEdge, addNode, node)
import Network.Position exposing (circle, position)
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
                |> addNode (node "root" <| position -1.001378564502442e-5 0.0)
                |> addNode (node "a" <| position 0.1668864136294297 0.2890617176808308)
                |> addNode (node "b" <| position -0.33380286861579445 0.0)
                |> addNode (node "c" <| position 0.1668864136294297 -0.28906171768083033)
                |> addNode (node "a1" <| position 0.644844402460721 0.1727694515838314)
                |> addNode (node "a2" <| position 0.4720732208006355 0.47204512834206747)
                |> addNode (node "a3" <| position 0.17279454715992348 0.6448145799258989)
                |> addNode (node "a4" <| position -0.17278119544573034 0.6448145799258989)
                |> addNode (node "b1" <| position -0.4720598690864424 0.47204512834206747)
                |> addNode (node "b2" <| position -0.6448310507465278 0.1727694515838314)
                |> addNode (node "b3" <| position -0.6448310507465278 -0.17276945158383117)
                |> addNode (node "b4" <| position -0.4720598690864424 -0.47204512834206747)
                |> addNode (node "c1" <| position -0.17278119544573034 -0.6448479588771321)
                |> addNode (node "c2" <| position 0.17279454715992348 -0.6448479588771321)
                |> addNode (node "c3" <| position 0.4720732208006355 -0.47204512834206747)
                |> addNode (node "c4" <| position 0.644844402460721 -0.17276945158383117)
                |> addNode (node "a1a" <| position 1.0 0.05240495343636309)
                |> addNode (node "a1b" <| position 0.9890515943615712 0.1566474181381221)
                |> addNode (node "a1c" <| position 0.967254920941162 0.2591541773757471)
                |> addNode (node "a1d" <| position 0.9348770140226379 0.35885710470976995)
                |> addNode (node "a1e" <| position 0.8922516664608278 0.4546213157982577)
                |> addNode (node "a2a" <| position 0.8398461882524944 0.5453786842017425)
                |> addNode (node "a2b" <| position 0.7782280272508484 0.6301612203344571)
                |> addNode (node "a2c" <| position 0.7080981484510342 0.7080676925131015)
                |> addNode (node "a2d" <| position 0.6301908961336775 0.7781968690543746)
                |> addNode (node "a2e" <| position 0.5454075110068193 0.8398144130311427)
                |> addNode (node "a3a" <| position 0.4546158544930188 0.8922193664675058)
                |> addNode (node "a3b" <| position 0.35888406372773174 0.9348442871924965)
                |> addNode (node "a3c" <| position 0.2591801379899661 0.9672552488400816)
                |> addNode (node "a3d" <| position 0.15667235227162735 0.9890517039954605)
                |> addNode (node "a3e" <| position 0.05242884370817169 1.0)
                |> addNode (node "a4a" <| position -0.052415491993978436 1.0)
                |> addNode (node "a4b" <| position -0.1566590005574342 0.9890517039954605)
                |> addNode (node "a4c" <| position -0.25916678627577294 0.9672552488400816)
                |> addNode (node "a4d" <| position -0.3588707120135387 0.9348442871924965)
                |> addNode (node "a4e" <| position -0.4546025027788255 0.8922193664675058)
                |> addNode (node "b1a" <| position -0.5453941592926261 0.8398144130311427)
                |> addNode (node "b1b" <| position -0.6301775444194841 0.7781968690543746)
                |> addNode (node "b1c" <| position -0.7080847967368411 0.7080676925131015)
                |> addNode (node "b1d" <| position -0.7782146755366555 0.6301612203344571)
                |> addNode (node "b1e" <| position -0.8398194848241078 0.5453786842017425)
                |> addNode (node "b2a" <| position -0.8922283009609896 0.4546213157982577)
                |> addNode (node "b2b" <| position -0.9348603243798963 0.35885710470976995)
                |> addNode (node "b2c" <| position -0.967251583012614 0.2591541773757471)
                |> addNode (node "b2d" <| position -0.9890449185044745 0.1566474181381221)
                |> addNode (node "b2e" <| position -1.0 0.05240495343636309)
                |> addNode (node "b3a" <| position -1.0 -0.05240495343636287)
                |> addNode (node "b3b" <| position -0.9890449185044745 -0.156647418138122)
                |> addNode (node "b3c" <| position -0.967251583012614 -0.2591875563269802)
                |> addNode (node "b3d" <| position -0.9348603243798963 -0.35885710470977006)
                |> addNode (node "b3e" <| position -0.8922283009609896 -0.4546213157982576)
                |> addNode (node "b4a" <| position -0.8398194848241078 -0.5453786842017423)
                |> addNode (node "b4b" <| position -0.7782146755366555 -0.6301945992856903)
                |> addNode (node "b4c" <| position -0.7080847967368411 -0.7080676925131012)
                |> addNode (node "b4d" <| position -0.6301775444194841 -0.778213558529991)
                |> addNode (node "b4e" <| position -0.5453941592926261 -0.8398210888213893)
                |> addNode (node "c1a" <| position -0.4546025027788255 -0.8922293801528756)
                |> addNode (node "c1b" <| position -0.3588707120135387 -0.9348609766681131)
                |> addNode (node "c1c" <| position -0.25916678627577294 -0.9672519109449581)
                |> addNode (node "c1d" <| position -0.1566590005574342 -0.9890450282052138)
                |> addNode (node "c1e" <| position -0.052415491993978436 -1.0)
                |> addNode (node "c2a" <| position 0.05242884370817169 -1.0)
                |> addNode (node "c2b" <| position 0.15667235227162735 -0.9890450282052138)
                |> addNode (node "c2c" <| position 0.2591801379899661 -0.9672519109449581)
                |> addNode (node "c2d" <| position 0.35888406372773174 -0.9348609766681131)
                |> addNode (node "c2e" <| position 0.4546158544930188 -0.8922293801528756)
                |> addNode (node "c3a" <| position 0.5454075110068193 -0.8398210888213893)
                |> addNode (node "c3b" <| position 0.6301908961336775 -0.778213558529991)
                |> addNode (node "c3c" <| position 0.7080981484510342 -0.7080676925131012)
                |> addNode (node "c3d" <| position 0.7782280272508484 -0.6301945992856903)
                |> addNode (node "c3e" <| position 0.8398461882524944 -0.5453786842017423)
                |> addNode (node "c4a" <| position 0.8922516664608278 -0.4546213157982576)
                |> addNode (node "c4b" <| position 0.9348770140226379 -0.35885710470977006)
                |> addNode (node "c4c" <| position 0.967254920941162 -0.2591875563269802)
                |> addNode (node "c4d" <| position 0.9890515943615712 -0.156647418138122)
                |> addNode (node "c4e" <| position 1.0 -0.05240495343636287)
                |> addEdge "root-a" "root" "a"
                |> addEdge "root-b" "root" "b"
                |> addEdge "root-c" "root" "c"
                |> addEdge "a-a1" "a" "a1"
                |> addEdge "a-a2" "a" "a2"
                |> addEdge "a-a3" "a" "a3"
                |> addEdge "a-a4" "a" "a4"
                |> addEdge "b-b1" "b" "b1"
                |> addEdge "b-b2" "b" "b2"
                |> addEdge "b-b3" "b" "b3"
                |> addEdge "b-b4" "b" "b4"
                |> addEdge "c-c1" "c" "c1"
                |> addEdge "c-c2" "c" "c2"
                |> addEdge "c-c3" "c" "c3"
                |> addEdge "c-c4" "c" "c4"
                |> addEdge "a1-a1a" "a1" "a1a"
                |> addEdge "a1-a1b" "a1" "a1b"
                |> addEdge "a1-a1c" "a1" "a1c"
                |> addEdge "a1-a1d" "a1" "a1d"
                |> addEdge "a1-a1e" "a1" "a1e"
                |> addEdge "a2-a2a" "a2" "a2a"
                |> addEdge "a2-a2b" "a2" "a2b"
                |> addEdge "a2-a2c" "a2" "a2c"
                |> addEdge "a2-a2d" "a2" "a2d"
                |> addEdge "a2-a2e" "a2" "a2e"
                |> addEdge "a3-a3a" "a3" "a3a"
                |> addEdge "a3-a3b" "a3" "a3b"
                |> addEdge "a3-a3c" "a3" "a3c"
                |> addEdge "a3-a3d" "a3" "a3d"
                |> addEdge "a3-a3e" "a3" "a3e"
                |> addEdge "a4-a4a" "a4" "a4a"
                |> addEdge "a4-a4b" "a4" "a4b"
                |> addEdge "a4-a4c" "a4" "a4c"
                |> addEdge "a4-a4d" "a4" "a4d"
                |> addEdge "a4-a4e" "a4" "a4e"
                |> addEdge "b1-b1a" "b1" "b1a"
                |> addEdge "b1-b1b" "b1" "b1b"
                |> addEdge "b1-b1c" "b1" "b1c"
                |> addEdge "b1-b1d" "b1" "b1d"
                |> addEdge "b1-b1e" "b1" "b1e"
                |> addEdge "b2-b2a" "b2" "b2a"
                |> addEdge "b2-b2b" "b2" "b2b"
                |> addEdge "b2-b2c" "b2" "b2c"
                |> addEdge "b2-b2d" "b2" "b2d"
                |> addEdge "b2-b2e" "b2" "b2e"
                |> addEdge "b3-b3a" "b3" "b3a"
                |> addEdge "b3-b3b" "b3" "b3b"
                |> addEdge "b3-b3c" "b3" "b3c"
                |> addEdge "b3-b3d" "b3" "b3d"
                |> addEdge "b3-b3e" "b3" "b3e"
                |> addEdge "b4-b4a" "b4" "b4a"
                |> addEdge "b4-b4b" "b4" "b4b"
                |> addEdge "b4-b4c" "b4" "b4c"
                |> addEdge "b4-b4d" "b4" "b4d"
                |> addEdge "b4-b4e" "b4" "b4e"
                |> addEdge "c1-c1a" "c1" "c1a"
                |> addEdge "c1-c1b" "c1" "c1b"
                |> addEdge "c1-c1c" "c1" "c1c"
                |> addEdge "c1-c1d" "c1" "c1d"
                |> addEdge "c1-c1e" "c1" "c1e"
                |> addEdge "c2-c2a" "c2" "c2a"
                |> addEdge "c2-c2b" "c2" "c2b"
                |> addEdge "c2-c2c" "c2" "c2c"
                |> addEdge "c2-c2d" "c2" "c2d"
                |> addEdge "c2-c2e" "c2" "c2e"
                |> addEdge "c3-c3a" "c3" "c3a"
                |> addEdge "c3-c3b" "c3" "c3b"
                |> addEdge "c3-c3c" "c3" "c3c"
                |> addEdge "c3-c3d" "c3" "c3d"
                |> addEdge "c3-c3e" "c3" "c3e"
                |> addEdge "c4-c4a" "c4" "c4a"
                |> addEdge "c4-c4b" "c4" "c4b"
                |> addEdge "c4-c4c" "c4" "c4c"
                |> addEdge "c4-c4d" "c4" "c4d"
                |> addEdge "c4-c4e" "c4" "c4e"

        cmd =
            Network.randomEdge network
                |> Random.generate (Broken "root")

        code =
            "A1b-"
    in
    Browser.element
        { init = \_ -> ( Initializing code context network, cmd )
        , update = update
        , view = view >> Svg.toUnstyled
        , subscriptions = \_ -> Sub.none
        }


type Model
    = Initializing Code Context Network
    | Initialized Context Problem
    | Failed


type Msg
    = ProblemMsg Problem.Msg
    | Broken NodeId (Maybe EdgeId)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ProblemMsg m, Initialized context problem ) ->
            let
                ( p, cmd ) =
                    Problem.update context m problem
            in
            ( Initialized context p, Cmd.map ProblemMsg cmd )

        ( Broken v (Just e), Initializing code context network ) ->
            let
                problem =
                    Problem.problem network v e code
            in
            ( Initialized context problem, Cmd.none )

        ( Broken _ Nothing, Initializing _ _ _ ) ->
            ( Failed, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Svg Msg
view model =
    case model of
        Initializing _ _ network ->
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
        [ Svg.text_ [ Attribute.x "0", Attribute.y "15" ] [ Svg.text "Could not generate a broken edge" ]
        ]
