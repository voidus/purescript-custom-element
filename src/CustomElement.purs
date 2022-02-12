module CustomElement where

import Prelude

import Control.Monad.Identity.Trans (IdentityT)
import Control.Monad.State.Class (class MonadState)
import Control.Monad.State.Trans (StateT, execStateT)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(Just, Nothing), fromJust)
import Data.Tuple(Tuple(Tuple), fst, snd)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Console (log)
import Partial (crash)
import Partial.Unsafe (unsafePartial)
import Type.Proxy (Proxy)


newtype MCustomElement state a = MCustomElement (StateT state Effect a)

derive newtype instance mCustomElement_Functor :: Functor (MCustomElement state)
derive newtype instance mCustomElement_Apply :: Apply (MCustomElement state)
derive newtype instance mCustomElement_Applicative :: Applicative (MCustomElement state)
derive newtype instance mCustomElement_Monad :: Monad (MCustomElement state)
derive newtype instance mCustomElement_MonadEffect :: MonadEffect (MCustomElement state)
derive newtype instance mCustomElement_Bind :: Bind (MCustomElement state)
derive newtype instance mCustomElement_MonadState :: MonadState state (MCustomElement state)

type Callbacks state observedAttributes = {
    connected :: MCustomElement state Unit,
    disconnected :: MCustomElement state Unit,
    adopted :: MCustomElement state Unit,
    attributeChanged :: observedAttributes -> Maybe String -> Maybe String -> MCustomElement state Unit
}

type RunMCustomElement = forall state. state -> MCustomElement state Unit -> Effect state
runMCustomElement :: RunMCustomElement
runMCustomElement state (MCustomElement m) = execStateT m state


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

        attributeChanged :: String -> Maybe String -> Maybe String -> MCustomElement state Unit
        attributeChanged attrString o n =
            spec.callbacks.attributeChanged attribute o n
            where
                attribute :: observedAttributes
                attribute = Map.lookup attrString attributesByString # unsafePartial fromJust

        wrappedSpec :: Spec state String
        wrappedSpec = spec { callbacks { attributeChanged = attributeChanged } }
     in
        define_ runMCustomElement name observedAttributes wrappedSpec
