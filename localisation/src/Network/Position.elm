module Network.Position exposing (Position, add, circle, position, scale, xCoordinate, yCoordinate)


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


circle : Float -> Float -> Position
circle radius angle =
    let
        x =
            radius * cos angle

        y =
            radius * sin angle
    in
    position x y


xCoordinate : Position -> Float
xCoordinate (Position { x }) =
    x


yCoordinate : Position -> Float
yCoordinate (Position { y }) =
    y


add : Position -> Position -> Position
add left right =
    position
        (xCoordinate left + xCoordinate right)
        (yCoordinate left + yCoordinate right)


scale : Float -> Position -> Position
scale factor p =
    position
        (factor * xCoordinate p)
        (factor * yCoordinate p)
