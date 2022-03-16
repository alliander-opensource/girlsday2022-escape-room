module Problem exposing (Context, Msg, Problem, Status, problem, update, view)

import Code exposing (Code)
import Dict exposing (Dict)
import Network exposing (EdgeId, Network, NodeId)
import Network.Path as Path
import Network.Position as Position
import Random
import Set exposing (Set)
import Svg.Styled as Svg exposing (Svg)
import Svg.Styled.Attributes as Attribute


type Problem
    = Problem
        { network : Network
        , root : NodeId
        , faulty : EdgeId
        , code : Visibility Code
        , status : Dict NodeId Status
        }


type Visibility a
    = Hidden a
    | Visible a


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
        , code = Hidden code
        , status =
            Dict.empty
                |> Dict.insert root Alive
        }


type Msg
    = Determine NodeId


update : Msg -> Problem -> Problem
update msg prblm =
    case msg of
        Determine v ->
            if statusKnown v prblm then
                prblm

            else if reachable v prblm then
                prblm
                    |> alive v
                    |> solved

            else
                prblm
                    |> dead v
                    |> solved


statusKnown : NodeId -> Problem -> Bool
statusKnown v (Problem p) =
    Dict.member v p.status


reachable : NodeId -> Problem -> Bool
reachable v (Problem p) =
    Network.paths p.root v p.network
        |> List.filter (not << Path.over p.faulty)
        |> List.isEmpty
        |> not


alive : NodeId -> Problem -> Problem
alive v (Problem p) =
    Problem { p | status = p.status |> Dict.insert v Alive }


dead : NodeId -> Problem -> Problem
dead v (Problem p) =
    Problem { p | status = p.status |> Dict.insert v Dead }


solved : Problem -> Problem
solved (Problem p) =
    let
        isSolved =
            p.network
                |> Network.endpoints p.faulty
                |> all (\v -> known (Dict.get v p.status |> Maybe.withDefault Indetermined))

        code =
            if isSolved then
                show p.code

            else
                hide p.code
    in
    Problem { p | code = code }


all : (a -> Bool) -> Set a -> Bool
all predicate elements =
    elements
        |> Set.toList
        |> List.all predicate


known : Status -> Bool
known s =
    case s of
        Indetermined ->
            False

        _ ->
            True


show : Visibility a -> Visibility a
show =
    target >> Visible


hide : Visibility a -> Visibility a
hide =
    target >> Hidden


target : Visibility a -> a
target vs =
    case vs of
        Visible v ->
            v

        Hidden v ->
            v




type alias Context =
    { network : Network.Context
    , problem :
        { status : StatusContext
        , code : CodeContext
        }
    }


type alias StatusContext =
    { alive : String
    , dead : String
    , indetermined : String
    }


type alias CodeContext =
    { size : Float
    , fill : String
    }


view : Context -> Problem -> List (Svg Msg)
view context ((Problem p) as prblm) =
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
    List.concat
        [ Network.view context.network nodeColor Determine p.network
        , viewCode context.problem.code prblm
        ]


viewCode : CodeContext -> Problem -> List (Svg a)
viewCode context (Problem p) =
    case p.code of
        Visible code ->
            let
                endpoints =
                    p.network
                        |> Network.endpoints p.faulty
                        |> Set.toList
                        |> List.map (\v -> Network.locationOf v p.network |> Maybe.withDefault (Position.position 0 0))

                position =
                    endpoints
                        |> List.foldl Position.add (Position.position 0 0)
                        |> Position.scale (1 / toFloat (List.length endpoints))
            in
            [ Svg.g [ Attribute.id "codes" ]
                [ Svg.text_
                    [ Attribute.x <| String.fromFloat <| Position.xCoordinate position
                    , Attribute.y <| String.fromFloat <| Position.yCoordinate position
                    , Attribute.fill context.fill 
                    , Attribute.fontSize <| (String.fromFloat context.size) ++ "px" ]
                    [ Svg.text code ]
                ]
            ]

        Hidden _ ->
            []
