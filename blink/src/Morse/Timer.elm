module Morse.Timer exposing (Timer, elapsed, update, from)

import Time exposing (Posix)


type Timer
    = Timer
        { start : Posix
        , last : Posix
        }


from : Posix -> Timer
from posix =
    Timer
        { start = posix
        , last = posix
        }


elapsed : Timer -> Int
elapsed (Timer { start, last }) =
    Time.posixToMillis last - Time.posixToMillis start


update : Posix -> Timer -> Timer
update posix (Timer t) =
    Timer { t | last = posix }
