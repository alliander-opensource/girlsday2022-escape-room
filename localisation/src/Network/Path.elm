module Network.Path exposing (Path, add, begin, contains, empty, end, length, over)


type Path v e
    = Path
        { start : v
        , steps : List ( e, v )
        }


empty : v -> Path v e
empty start =
    Path { start = start, steps = [] }


add : e -> v -> Path v e -> Path v e
add edge vertex (Path path) =
    Path { path | steps = ( edge, vertex ) :: path.steps }


begin : Path v e -> v
begin (Path { start }) =
    start


end : Path v e -> v
end (Path { start, steps }) =
    steps
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault start


contains : v -> Path v e -> Bool
contains needle path =
    List.member needle <| vertices path


vertices : Path v e -> List v
vertices (Path path) =
    let
        followers =
            path.steps
                |> List.map Tuple.second
                |> List.reverse
    in
    path.start :: followers


over : e -> Path v e -> Bool
over needle path =
    List.member needle <| edges path


edges : Path v e -> List e
edges (Path path) =
    path.steps
        |> List.map Tuple.first


length : Path v e -> Int
length (Path path) =
    List.length path.steps
