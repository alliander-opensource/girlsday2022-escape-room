module Code exposing (Code, code, avoiding)

import Random exposing (Generator)

type alias Code = String

code : Generator Code
code =
    let
        first =
            Random.uniform "A" [ "B" ]

        second =
            Random.uniform "0" [ "1" ]

        third =
            Random.uniform "a" [ "b" ]

        fourth =
            Random.uniform "-" [ "+" ]

        combine u v w x =
            u ++ v ++ w ++ x
    in
    Random.map4 combine first second third fourth


avoiding : Code -> Generator Code -> Generator Code
avoiding special generator =
    let
        choose candidate =
            if candidate == special then
                Random.lazy <| \_ -> avoiding special generator

            else
                Random.constant candidate
    in
    generator
        |> Random.andThen choose
