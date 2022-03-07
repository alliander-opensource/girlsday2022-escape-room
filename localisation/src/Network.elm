module Network exposing (Context, EdgeId, Network, Node, NodeId, Position, addEdge, addNode, empty, node, paths, position, view)

import Dict exposing (Dict)
import Network.Path as Path exposing (Path)
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


type Position
    = Position
        { x : Float
        , y : Float
        }


position : Float -> Float -> Position
position x y =
    Position
        { x = x
        , y = y
        }


xCoordinate : Position -> Float
xCoordinate (Position { x }) =
    x


yCoordinate : Position -> Float
yCoordinate (Position { y }) =
    y


type alias EdgeId =
    String


type Edge
    = Edge
        { id : String
        , start : ( NodeId, Position )
        , finish : ( NodeId, Position )
        }


edges : Network -> List Edge
edges (Network network) =
    let
        locationOf : NodeId -> Position
        locationOf start =
            network.nodes
                |> Dict.get start
                |> Maybe.map positionOf
                |> Maybe.withDefault (position 0 0)

        connection : NodeId -> ( EdgeId, NodeId ) -> Edge
        connection start ( id, finish ) =
            Edge
                { id = id
                , start = ( start, locationOf start )
                , finish = ( finish, locationOf finish )
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


view : Context -> (NodeId -> String) -> (NodeId -> a) -> Network -> Svg a
view context nodeColor nodeOnClick (Network network) =
    let
        nodes =
            network.nodes
                |> Dict.toList
                |> List.map Tuple.second

        offset =
            context.node.radius + context.node.strokeWidth

        viewBox =
            [ -1 - offset, -1 - offset, 2 + 2 * offset, 2 + 2 * offset ]
                |> List.map String.fromFloat
                |> String.join " "
    in
    Svg.svg
        [ Attribute.width <| String.fromInt context.size
        , Attribute.height <| String.fromInt context.size
        , Attribute.viewBox viewBox
        ]
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
                |> xCoordinate
                |> String.fromFloat

        y =
            v.position
                |> yCoordinate
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
        , Attribute.x1 <| String.fromFloat <| xCoordinate s
        , Attribute.y1 <| String.fromFloat <| yCoordinate s
        , Attribute.x2 <| String.fromFloat <| xCoordinate f
        , Attribute.y2 <| String.fromFloat <| yCoordinate f
        ]
        []