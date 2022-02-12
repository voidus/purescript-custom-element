module Main where

import Prelude

import Data.Generic.Rep as G
import Type.Proxy (Proxy(Proxy))
import Data.Show.Generic as GS
import Data.String as String
import Effect (Effect)
import Effect.Console (log)
import Control.Monad.Reader (ask)
import Data.Maybe (Maybe)
import Effect.Class (liftEffect)
import CustomElement
import Control.Monad.Trans.Class (lift)
import Control.Monad.State.Trans (StateT)
import Control.Monad.State.Class as S
import Web.HTML.HTMLElement (toNode)
import Web.DOM.Node (setTextContent)

data Attribute
    = Foo
    | Bar

derive instance genericAttribute :: G.Generic Attribute _
instance showAttribute :: Show Attribute where
    show = GS.genericShow
instance observedAttributeAttribute :: ObservedAttribute Attribute where
    toString = show >>> String.toLower
    all = [Foo, Bar]

type State = {
    blurbs :: Int
}

initial :: State
initial = {
    blurbs: 42
}

attributeChanged :: Attribute -> Maybe String -> Maybe String -> MCustomElement State Unit
attributeChanged attr old new = do
    { blurbs } <- S.modify \s -> s { blurbs = s.blurbs + 1 }
    this <- ask
    liftEffect $ setTextContent ("Wow! " <> show blurbs <> " blurbs!") (toNode this)
    liftEffect $ case attr of
        Foo -> log "fuuuuu"
        Bar -> log "babbrbabrbababbabab"


main :: Effect Unit
main =
    define
    "foo-bar"
    (Proxy :: Proxy Attribute) {
        initial: initial,
        callbacks: {
            connected: liftEffect $ log "connected",
            disconnected: liftEffect $ log "disconnected",
            adopted: liftEffect $ log "adopted",
            attributeChanged: attributeChanged
        }
    }
