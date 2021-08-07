module MaybeUtils exposing (maybeCompare)

import Parser
import Time


maybeCompare : (a -> a -> Order) -> Maybe a -> Maybe a -> Order
maybeCompare f a b =
    case a of
        Just some_a ->
            case b of
                Just some_b ->
                    f some_a some_b

                Nothing ->
                    GT

        Nothing ->
            LT



-- sorting Posix time
-- https://stackoverflow.com/questions/60550236/sorting-list-of-objects-containing-maybe-time-posix


posixCompare : Time.Posix -> Time.Posix -> Order
posixCompare a b =
    compare (Time.posixToMillis a) (Time.posixToMillis b)


timeWithDefault : Result (List Parser.DeadEnd) Time.Posix -> Time.Posix
timeWithDefault time =
    let
        -- Jan 1st 2010
        defaultTime =
            Time.millisToPosix 1262304000000
    in
    Result.withDefault defaultTime time


timeCompare :
    Result (List Parser.DeadEnd) Time.Posix
    -> Result (List Parser.DeadEnd) Time.Posix
    -> Order
timeCompare time1 time2 =
    posixCompare (timeWithDefault time1) (timeWithDefault time2)
