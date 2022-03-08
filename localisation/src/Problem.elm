module Problem exposing (Context, Msg, Problem, Status, problem, update, view, label)

import Code exposing (Code)
import Dict exposing (Dict)
import Network exposing (EdgeId, Network, NodeId)
import Network.Path as Path
import Random
import Svg exposing (Svg)


type Problem
    = Problem
        { network : Network
        , root : NodeId
        , faulty : EdgeId
        , code : Code
        , status : Dict NodeId Status
        , codes : Dict EdgeId String
        }


type Status
    = Alive
    | Dead
    | Indetermined


problem : Network -> NodeId -> EdgeId -> Code -> Problem
problem network root faulty code =
    Problem
        { network = network
        , root = root
        , faulty = faulty
        , code = code
        , status =
            Dict.empty
                |> Dict.insert root Alive
        , codes = Dict.empty
        }


type Msg
    = Determine NodeId
    | Label EdgeId String


update : Msg -> Problem -> Problem
update msg ((Problem p) as prblm) =
    case msg of
        Determine v ->
            if Dict.member v p.status then
                prblm

            else if reachable v prblm then
                Problem { p | status = p.status |> Dict.insert v Alive }

            else
                Problem { p | status = p.status |> Dict.insert v Dead }

        Label e code ->
            Problem { p | codes = p.codes |> Dict.insert e code }


reachable : NodeId -> Problem -> Bool
reachable v (Problem p) =
    Network.paths p.root v p.network
        |> List.filter (not << Path.over p.faulty)
        |> List.isEmpty
        |> not


label : Problem -> Cmd Msg
label ((Problem p) as prblm) =
    let
        generator =
            Code.avoiding p.code Code.code
    in
    p.network
        |> Network.edges
        |> List.map Network.edgeId
        |> List.map Label
        |> List.map (\msg -> Random.generate msg generator)
        |> Cmd.batch


type alias Context =
    { network : Network.Context
    , problem :
        { status : StatusContext
        }
    }


type alias StatusContext =
    { alive : String
    , dead : String
    , indetermined : String
    }


view : Context -> Problem -> Svg Msg
view context (Problem p) =
    let
        toColor status =
            case status of
                Alive ->
                    context.problem.status.alive

                Dead ->
                    context.problem.status.dead

                Indetermined ->
                    context.problem.status.indetermined

        nodeColor nodeId =
            Dict.get nodeId p.status
                |> Maybe.withDefault Indetermined
                |> toColor
    in
    Network.view context.network nodeColor Determine p.network
