module Problem exposing (Problem, Msg, Status, problem, update, view)

import Dict exposing (Dict)
import Network exposing (Context, EdgeId, Network, NodeId)
import Network.Path as Path
import Svg exposing (Svg)
import Svg.Attributes as Attributes


type Problem
    = Problem
        { network : Network
        , root : NodeId
        , faulty : EdgeId
        , status : Dict NodeId Status
        }


type Status
    = Alive
    | Dead
    | Indetermined


problem : Network -> NodeId -> EdgeId -> Problem
problem network root faulty =
    Problem
        { network = network
        , root = root
        , faulty = faulty
        , status = Dict.empty
        }


type Msg
    = Determine NodeId


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


reachable : NodeId -> Problem -> Bool
reachable v (Problem p) =
    Network.paths p.root v p.network
        |> List.filter (not << Path.over p.faulty)
        |> List.isEmpty
        |> not


view : Context -> Problem -> Svg Msg
view context (Problem p) =
    let
        toColor status =
            case status of
                Alive ->
                    "green"

                Dead ->
                    "red"

                Indetermined ->
                    "white"

        nodeColor nodeId =
            Dict.get nodeId p.status
                |> Maybe.withDefault Indetermined
                |> toColor
    in
    Network.view context nodeColor (Determine) p.network
