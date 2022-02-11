module CustomElement (
    class ObservedAttribute,
    toString,
    all,

    Callbacks,
    Spec,
    define
    ) where

import Prelude

import Data.Maybe (Maybe, fromJust)
import Partial.Unsafe (unsafePartial)
import Data.HashMap as Map
import Type.Proxy (Proxy)
import Data.Enum (class BoundedEnum, upFromIncluding)
import Data.Bounded (bottom)
import Effect (Effect)


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
      attrMap :: Map.HashMap String observedAttributes
      attrMap = Map.fromArrayBy toString identity all

      wrappedAttributeChanged :: String -> Maybe String -> Maybe String -> Effect Unit
      wrappedAttributeChanged attrString =
          spec.callbacks.attributeChanged (unsafePartial $ fromJust $ Map.lookup attrString attrMap)

      updatedSpec :: Spec String
      updatedSpec = spec { callbacks { attributeChanged = wrappedAttributeChanged } }
