module CustomElement where

import Prelude

import Data.Maybe (Maybe(Just, Nothing), fromJust)
import Partial.Unsafe (unsafePartial)
import Data.Tuple(Tuple(Tuple), fst, snd)
import Data.Map as Map
import Data.Map (Map)
import Control.Monad.Identity.Trans (IdentityT)
import Partial (crash)
import Control.Monad.State.Trans (StateT, execStateT)
import Type.Proxy (Proxy)
import Effect (Effect)
import Effect.Console (log)


type MCustomElement state = StateT state Effect Unit

type RunMCustomElement = forall state. state -> MCustomElement state -> Effect state
runMCustomElement :: RunMCustomElement
runMCustomElement state m = execStateT m state

type Callbacks state observedAttributes = {
    connected :: MCustomElement state,
    disconnected :: MCustomElement state,
    adopted :: MCustomElement state,
    attributeChanged :: observedAttributes -> Maybe String -> Maybe String -> MCustomElement state
}

type Spec state observedAttributes = {
    initial :: state,
    callbacks :: Callbacks state observedAttributes
}

class ObservedAttribute a where
    -- Laws:
    --   (toString x) `matches` [a-z-_]+
    toString :: a -> String
    all :: Array a

allStrings :: forall a. ObservedAttribute a => Proxy a -> Array String
allStrings _ = map (toString :: a -> String) all


foreign import define_
    :: forall state observedAttributes

     . RunMCustomElement
    -> String
    -> Array String
    -> Spec state observedAttributes
    -> Effect Unit


define
    :: forall state observedAttributes

     . ObservedAttribute observedAttributes
    => Show observedAttributes

    => String
    -> Proxy observedAttributes
    -> Spec state observedAttributes

    -> Effect Unit
define name observedAttrsProxy spec =
    let
        observedAttributes :: Array String
        observedAttributes = allStrings observedAttrsProxy

        attributesByString :: Map String observedAttributes
        attributesByString =
            map (\attr -> Tuple (toString attr) attr) all
            # Map.fromFoldable

        attributeChanged :: String -> Maybe String -> Maybe String -> MCustomElement state
        attributeChanged attrString o n =
            spec.callbacks.attributeChanged attribute o n
            where
                attribute = Map.lookup attrString attributesByString # unsafePartial fromJust

        wrappedSpec = spec { callbacks { attributeChanged = attributeChanged } }
     in
        define_ runMCustomElement name observedAttributes wrappedSpec
