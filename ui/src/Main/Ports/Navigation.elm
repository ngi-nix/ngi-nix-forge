port module Main.Ports.Navigation exposing (navCmd, onNavEvent)

import Navigation


port navCmd : Navigation.CommandPort msg


port onNavEvent : Navigation.EventPort msg
