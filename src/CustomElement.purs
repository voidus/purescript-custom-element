module CustomElement (
    class ObservedAttribute,
    toString,
    all,

    Callbacks,
    Spec,
    define
    ) where

import Prelude

import Data.Maybe (Maybe(Just, Nothing), fromJust)
import Partial.Unsafe (unsafePartial)
import Data.Tuple(Tuple(Tuple))
import Data.Map as Map
import Partial (crash)
import Type.Proxy (Proxy)
import Effect (Effect)
import Effect.Console (log)


type Callbacks observedAttributes = {
    connected :: Effect Unit,
    disconnected :: Effect Unit,
    adopted :: Effect Unit,
    attributeChanged :: observedAttributes -> Maybe String -> Maybe String -> Effect Unit
}

type Spec observedAttributes = {
    callbacks :: Callbacks observedAttributes
}

class ObservedAttribute a where
    -- Laws:
    --   (toString x) `matches` [a-z-_]+
    toString :: a -> String
    all :: Array a

allStrings :: forall a. ObservedAttribute a => Proxy a -> Array String
allStrings _ = map (toString :: a -> String) all

foreign import define_
    :: String
    -> Array String
    -> Spec String
    -> Effect Unit

define
    :: forall observedAttributes

     . ObservedAttribute observedAttributes
    => Show observedAttributes

    => String
    -> Proxy observedAttributes
    -> Spec observedAttributes

    -> Effect Unit
define name observedAttrsProxy spec
    = define_ name (allStrings observedAttrsProxy) updatedSpec
    where 
      attrMap :: Map.Map String observedAttributes
      attrMap = Map.fromFoldable $ map (\a -> Tuple (toString a) a) all

      wrappedAttributeChanged :: String -> Maybe String -> Maybe String -> Effect Unit
      wrappedAttributeChanged attrString o n =
          spec.callbacks.attributeChanged attribute o n
          where
            attribute = Map.lookup attrString attrMap # unsafePartial fromJust

      updatedSpec :: Spec String
      updatedSpec = spec { callbacks { attributeChanged = wrappedAttributeChanged } }
