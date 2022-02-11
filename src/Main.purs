module Main where

import Prelude

import Data.Generic.Rep as G
import Type.Proxy (Proxy(Proxy))
import Data.Show.Generic as GS
import Data.String as String
import Effect (Effect)
import Effect.Console (log)
import Data.Maybe (Maybe, fromMaybe)
import CustomElement (define, class ObservedAttribute)

data Attribute
    = Foo
    | Bar

derive instance genericAttribute :: G.Generic Attribute _
instance showAttribute :: Show Attribute where
    show = GS.genericShow
instance observedAttributeAttribute :: ObservedAttribute Attribute where
    toString = show >>> String.toLower
    all = [Foo, Bar]

attributeChanged :: Attribute -> Maybe String -> Maybe String -> Effect Unit
attributeChanged attr old new =
    case attr of
        Foo -> log "fuuuuu"
        Bar -> log "bäh"


main :: Effect Unit
main = do
    define "foo-bar" (Proxy :: Proxy Attribute) {
        callbacks: {
            connected: log "connected",
            disconnected: log "disconnected",
            adopted: log "adopted",
            attributeChanged: attributeChanged
        }
    }
