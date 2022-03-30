module Problem exposing (Context, Msg, Problem, Status, isDetermining, problem, update, view)

import Code exposing (Code)
import Delay
import Dict exposing (Dict)
import Network exposing (EdgeId, Network, NodeId)
import Network.Path as Path
import Network.Position as Position
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
        , determining : State
        }


type Visibility a
    = Hidden a
    | Visible a


type Status
    = Alive
    | Dead
    | Indetermined


type State
    = Idle
    | Determining NodeId


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
        , determining = Idle
        }


type Msg
    = Determine NodeId
    | Determined Bool NodeId


update : Context -> Msg -> Problem -> ( Problem, Cmd Msg )
update context msg prblm =
    case msg of
        Determine v ->
            if statusKnown v prblm || isDetermining prblm then
                ( prblm, Cmd.none )

            else
                ( prblm
                    |> determining v
                , Delay.after context.problem.delay <| Determined (reachable v prblm) v
                )

        Determined isReachable v ->
            if isReachable then
                ( prblm
                    |> determined
                    |> alive v
                    |> solved
                , Cmd.none
                )

            else
                ( prblm
                    |> determined
                    |> dead v
                    |> solved
                , Cmd.none
                )


statusKnown : NodeId -> Problem -> Bool
statusKnown v (Problem p) =
    Dict.member v p.status


isDetermining : Problem -> Bool
isDetermining (Problem p) =
    case p.determining of
        Idle ->
            False

        Determining _ ->
            True


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


determined : Problem -> Problem
determined (Problem p) =
    Problem { p | determining = Idle }


determining : NodeId -> Problem -> Problem
determining v (Problem p) =
    Problem { p | determining = Determining v }


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
        , delay : Int
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
                    , Attribute.fontSize <| String.fromFloat context.size ++ "px"
                    ]
                    [ Svg.text code ]
                ]
            ]

        Hidden _ ->
            []
