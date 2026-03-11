module Tests exposing (suite)

import Expect
import Test exposing (Test)


suite : Test
suite =
    Test.test "This test should pass" (\_ -> Expect.pass)
