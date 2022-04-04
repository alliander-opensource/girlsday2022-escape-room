module Blink exposing (..)

import Browser
import Morse exposing (Context, Msg(..), Player)
import Morse.Timer as Timer exposing (Timer)
import Svg.Styled as Svg exposing (Svg)
import Task
import Time


main : Program () Model Msg
main =
    let
        context =
            { unit_duration = 1000
            , size = 640
            , radius = 0.9
            , strokeWidth = 0.05
            , stroke = "gray"
            , on = "black"
            , off = "white"
            }
    in
    Browser.element
        { init = \_ -> ( Initializing context "ALPHA ONE", Task.perform Tick Time.now )
        , update = update
        , view = view context >> Svg.toUnstyled
        , subscriptions = subscriptions
        }


type Model
    = Initializing Context String
    | Initialized Player


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        m =
            case ( msg, model ) of
                ( Tick posix, Initializing context message ) ->
                    let
                        timer =
                            Timer.from posix

                        player =
                            Morse.fromString context timer message
                    in
                    Initialized player

                ( Tick _, Initialized player ) ->
                    Initialized <| Morse.update msg player
    in
    ( m, Cmd.none )


view : Context -> Model -> Svg Msg
view context model =
    case model of
        Initializing _ _ ->
            Svg.svg [] []

        Initialized player ->
            Morse.view context player


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 100 Tick
