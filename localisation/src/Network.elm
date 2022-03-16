module Network exposing (Context, Edge, EdgeId, Network, Node, NodeId, addEdge, addNode, edgeId, edges, empty, endpoints, node, paths, view, locationOf)

import Dict exposing (Dict)
import Html.Attributes exposing (start)
import Network.Path as Path exposing (Path)
import Network.Position as Position exposing (Position, position)
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Attributes as Attribute
import Svg.Events as Event


type Network
    = Network
        { nodes : Dict NodeId Node
        , edges : Dict NodeId (Set ( EdgeId, NodeId ))
        }


empty : Network
empty =
    Network
        { nodes = Dict.empty
        , edges = Dict.empty
        }


addNode : Node -> Network -> Network
addNode ((Node { id }) as v) (Network network) =
    Network
        { network
            | nodes = network.nodes |> Dict.insert id v
        }


addEdge : EdgeId -> NodeId -> NodeId -> Network -> Network
addEdge id start finish (Network network) =
    Network
        { network
            | edges =
                network.edges
                    |> Dict.update start (addConnectionTo id finish)
                    |> Dict.update finish (addConnectionTo id start)
        }


addConnectionTo : EdgeId -> NodeId -> Maybe (Set ( EdgeId, NodeId )) -> Maybe (Set ( EdgeId, NodeId ))
addConnectionTo id finish connections =
    case connections of
        Nothing ->
            Set.singleton ( id, finish )
                |> Just

        Just c ->
            c
                |> Set.insert ( id, finish )
                |> Just


type alias NodeId =
    String


type Node
    = Node
        { id : NodeId
        , position : Position
        }


node : NodeId -> Position -> Node
node id p =
    Node
        { id = id
        , position = p
        }


positionOf : Node -> Position
positionOf (Node v) =
    v.position


locationOf : NodeId -> Network -> Maybe Position
locationOf start (Network network) =
    network.nodes
        |> Dict.get start
        |> Maybe.map positionOf


type alias EdgeId =
    String


type Edge
    = Edge
        { id : String
        , start : ( NodeId, Position )
        , finish : ( NodeId, Position )
        }


edgeId : Edge -> EdgeId
edgeId (Edge { id }) =
    id


edges : Network -> List Edge
edges ((Network network) as net) =
    let
        connection : NodeId -> ( EdgeId, NodeId ) -> Edge
        connection start ( id, finish ) =
            Edge
                { id = id
                , start = ( start, locationOf start net |> Maybe.withDefault (position 0 0) )
                , finish = ( finish, locationOf finish net |> Maybe.withDefault (position 0 0) )
                }

        connect : ( NodeId, Set ( EdgeId, NodeId ) ) -> List Edge
        connect ( start, finishes ) =
            finishes
                |> Set.toList
                |> List.map (connection start)
    in
    network.edges
        |> Dict.toList
        |> List.concatMap connect


endpoints : EdgeId -> Network -> Set NodeId
endpoints target network =
    let
        ends (Edge { start, finish }) =
            [ Tuple.first start, Tuple.first finish ]
    in
    network
        |> edges
        |> List.filter (edgeId >> (==) target)
        |> List.concatMap ends
        |> Set.fromList


paths : NodeId -> NodeId -> Network -> List (Path NodeId EdgeId)
paths start finish net =
    explore [] [ ( Path.empty start, Set.empty ) ] finish net


explore : List (Path NodeId EdgeId) -> List ( Path NodeId EdgeId, Set EdgeId ) -> NodeId -> Network -> List (Path NodeId EdgeId)
explore accumulator candidates goal net =
    case List.head candidates of
        Just ( candidate, visited ) ->
            if goal == Path.end candidate then
                explore (candidate :: accumulator) (List.tail candidates |> Maybe.withDefault []) goal net

            else
                let
                    allowed : ( EdgeId, NodeId ) -> Bool
                    allowed ( e, v ) =
                        not <| Set.member e visited

                    end =
                        Path.end candidate

                    extentions =
                        edgesOf end net
                            |> Set.toList
                            |> List.filter allowed
                            |> List.map (\( e, v ) -> ( Path.add e v candidate, Set.insert e visited ))

                    nextCandidates =
                        List.concat
                            [ List.tail candidates |> Maybe.withDefault []
                            , extentions
                            ]
                in
                explore accumulator nextCandidates goal net

        Nothing ->
            List.sortBy Path.length accumulator


edgesOf : EdgeId -> Network -> Set ( EdgeId, NodeId )
edgesOf e (Network network) =
    Dict.get e network.edges
        |> Maybe.withDefault Set.empty


type alias Context =
    { size : Int
    , node : NodeContext
    , edge : EdgeContext
    }


type alias NodeContext =
    { radius : Float
    , strokeWidth : Float
    , stroke : String
    , fill : String
    }


type alias EdgeContext =
    { strokeWidth : Float
    , stroke : String
    }


view : Context -> (NodeId -> String) -> (NodeId -> a) -> Network -> List (Svg a)
view context nodeColor nodeOnClick (Network network) =
    let
        nodes =
            network.nodes
                |> Dict.toList
                |> List.map Tuple.second
    in
    [ Svg.g
        [ Attribute.id "edges"
        , Attribute.stroke context.edge.stroke
        , Attribute.strokeWidth <| String.fromFloat context.edge.strokeWidth
        ]
      <|
        List.map viewEdge (edges <| Network network)
    , Svg.g
        [ Attribute.id "nodes"
        , Attribute.stroke context.node.stroke
        , Attribute.fill context.node.fill
        , Attribute.strokeWidth <| String.fromFloat context.node.strokeWidth
        ]
      <|
        List.map (viewNode context.node nodeColor nodeOnClick) nodes
    ]


viewNode : NodeContext -> (NodeId -> String) -> (NodeId -> a) -> Node -> Svg a
viewNode context nodeColor nodeOnClick (Node v) =
    let
        x =
            v.position
                |> Position.xCoordinate
                |> String.fromFloat

        y =
            v.position
                |> Position.yCoordinate
                |> String.fromFloat

        r =
            context.radius
                |> String.fromFloat
    in
    Svg.circle
        [ Attribute.id v.id
        , Attribute.cx x
        , Attribute.cy y
        , Attribute.r r
        , Attribute.fill <| nodeColor v.id
        , Event.onClick (nodeOnClick v.id)
        ]
        []


viewEdge : Edge -> Svg a
viewEdge (Edge { id, start, finish }) =
    let
        identity =
            id ++ ":" ++ Tuple.first start ++ "-" ++ Tuple.first finish

        s =
            Tuple.second start

        f =
            Tuple.second finish
    in
    Svg.line
        [ Attribute.id identity
        , Attribute.x1 <| String.fromFloat <| Position.xCoordinate s
        , Attribute.y1 <| String.fromFloat <| Position.yCoordinate s
        , Attribute.x2 <| String.fromFloat <| Position.xCoordinate f
        , Attribute.y2 <| String.fromFloat <| Position.yCoordinate f
        ]
        []
