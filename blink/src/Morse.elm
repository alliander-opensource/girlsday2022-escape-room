module Morse exposing (Context, Msg(..), Player, fromString, update, view)

import Array exposing (Array)
import Morse.Timer as Timer exposing (Timer)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as Attribute
import Time exposing (Posix)


type alias Context =
    { unit_duration : Int
    , size : Int
    , radius : Float
    , strokeWidth : Float
    , stroke : String
    , on : String
    , off : String
    }


type Player
    = Player
        { signal : Array Signal
        , code : Code
        , duration : Int
        , timer : Timer
        }


type Signal
    = On
    | Off


fromString : Context -> Timer -> String -> Player
fromString context timer input =
    input
        |> toCode
        |> toSignal
        |> toPlayer context timer


type alias Code =
    List Element


type Element
    = Mark Mark
    | Gap Gap


type Mark
    = Dot
    | Dash


type Gap
    = Inter
    | Short
    | Medium


toCode : String -> Code
toCode input =
    input
        |> String.words
        |> List.map fromWord
        |> List.intersperse [ Gap Medium ]
        |> List.concat
        |> swap List.append [ Gap Medium ]


swap : (b -> a -> c) -> a -> b -> c
swap f a b =
    f b a


fromWord : String -> Code
fromWord word =
    let
        allowed c =
            Char.isAlpha c || Char.isDigit c
    in
    word
        |> String.toList
        |> List.map Char.toUpper
        |> List.filter allowed
        |> List.map fromCharacter
        |> List.intersperse [ Gap Short ]
        |> List.concat


fromCharacter : Char -> Code
fromCharacter c =
    let
        pattern : List Mark
        pattern =
            case c of
                'A' ->
                    [ Dot, Dash ]

                'B' ->
                    [ Dash, Dot, Dot, Dot ]

                'C' ->
                    [ Dash, Dot, Dash, Dot ]

                'D' ->
                    [ Dash, Dot, Dot ]

                'E' ->
                    [ Dot ]

                'F' ->
                    [ Dot, Dot, Dash, Dot ]

                'G' ->
                    [ Dash, Dash, Dot ]

                'H' ->
                    [ Dot, Dot, Dot, Dot ]

                'I' ->
                    [ Dot, Dot ]

                'J' ->
                    [ Dot, Dash, Dash, Dash ]

                'K' ->
                    [ Dash, Dot, Dash ]

                'L' ->
                    [ Dot, Dash, Dot, Dot ]

                'M' ->
                    [ Dash, Dash ]

                'N' ->
                    [ Dash, Dot ]

                'O' ->
                    [ Dash, Dash, Dash ]

                'P' ->
                    [ Dot, Dash, Dash, Dot ]

                'Q' ->
                    [ Dash, Dash, Dot, Dash ]

                'R' ->
                    [ Dot, Dash, Dot ]

                'S' ->
                    [ Dot, Dot, Dot ]

                'T' ->
                    [ Dash ]

                'U' ->
                    [ Dot, Dot, Dash ]

                'V' ->
                    [ Dot, Dot, Dot, Dash ]

                'W' ->
                    [ Dot, Dash, Dash ]

                'X' ->
                    [ Dash, Dot, Dot, Dash ]

                'Y' ->
                    [ Dash, Dot, Dash, Dash ]

                'Z' ->
                    [ Dash, Dash, Dot, Dot ]

                '0' ->
                    [ Dash, Dash, Dash, Dash, Dash ]

                '1' ->
                    [ Dot, Dash, Dash, Dash, Dash ]

                '2' ->
                    [ Dot, Dot, Dash, Dash, Dash ]

                '3' ->
                    [ Dot, Dot, Dot, Dash, Dash ]

                '4' ->
                    [ Dot, Dot, Dot, Dot, Dash ]

                '5' ->
                    [ Dot, Dot, Dot, Dot, Dot ]

                '6' ->
                    [ Dash, Dot, Dot, Dot, Dot ]

                '7' ->
                    [ Dash, Dash, Dot, Dot, Dot ]

                '8' ->
                    [ Dash, Dash, Dash, Dot, Dot ]

                '9' ->
                    [ Dash, Dash, Dash, Dash, Dot ]

                _ ->
                    []
    in
    pattern
        |> List.map Mark
        |> List.intersperse (Gap Inter)


toSignal : Code -> ( Code, Array Signal )
toSignal code =
    let
        toSig element =
            case element of
                Mark Dot ->
                    List.repeat 1 On

                Mark Dash ->
                    List.repeat 3 On

                Gap Inter ->
                    List.repeat 1 Off

                Gap Short ->
                    List.repeat 3 Off

                Gap Medium ->
                    List.repeat 7 Off
    in
    ( code
    , code
        |> List.concatMap toSig
        |> Array.fromList
    )


toPlayer : Context -> Timer -> ( Code, Array Signal ) -> Player
toPlayer context timer ( code, signal ) =
    Player
        { signal = signal
        , code = code
        , duration = context.unit_duration
        , timer = timer
        }


type Msg
    = Tick Posix


update : Msg -> Player -> Player
update msg (Player player) =
    case msg of
        Tick posix ->
            Player { player | timer = Timer.update posix player.timer }


view : Context -> Player -> Svg Msg
view context (Player { signal, duration, timer }) =
    let
        viewBox =
            [ -1, -1, 2, 2 ]
                |> List.map String.fromFloat
                |> String.join " "

        index =
            Timer.elapsed timer
                // duration
                |> modBy (Array.length signal)

        circle s =
            let
                color =
                    if s == On then
                        context.on

                    else
                        context.off
            in
            Svg.circle
                [ Attribute.cx <| String.fromFloat 0
                , Attribute.cy <| String.fromFloat 0
                , Attribute.r <| String.fromFloat context.radius
                , Attribute.strokeWidth <| String.fromFloat context.strokeWidth
                , Attribute.fill color
                , Attribute.stroke context.stroke
                ]
                []

        content =
            signal
                |> Array.get index
                |> Maybe.map circle
                |> Maybe.map List.singleton
                |> Maybe.withDefault []
    in
    Svg.svg
        [ Attribute.width <| String.fromInt context.size
        , Attribute.height <| String.fromInt context.size
        , Attribute.viewBox viewBox
        ]
        content
