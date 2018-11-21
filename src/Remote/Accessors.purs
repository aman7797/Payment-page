module Remote.Accessors where

import Prelude

import Data.Lens.Lens (Lens', lens)
import Data.Newtype (class Newtype, unwrap, wrap)

_status :: forall a b c. Newtype a { status :: b | c } => Lens' a b
_status =
  lens (unwrap >>> _.status) (\oldRec newVal -> wrap ((unwrap oldRec) { status = newVal }))

_payment :: forall a b c. Newtype a { payment :: b | c } => Lens' a b
_payment =
  lens (unwrap >>> _.payment) (\oldRec newVal -> wrap ((unwrap oldRec) { payment = newVal }))

_authentication :: forall a b c. Newtype a { authentication :: b | c } => Lens' a b
_authentication =
  lens (unwrap >>> _.authentication) (\oldRec newVal -> wrap ((unwrap oldRec) { authentication = newVal }))

_method :: forall a b c. Newtype a { method :: b | c } => Lens' a b
_method =
  lens (unwrap >>> _.method) (\oldRec newVal -> wrap ((unwrap oldRec) { method = newVal }))

_url :: forall a b c. Newtype a { url :: b | c } => Lens' a b
_url =
  lens (unwrap >>> _.url) (\oldRec newVal -> wrap ((unwrap oldRec) { url = newVal }))

_params :: forall a b c. Newtype a { params :: b | c } => Lens' a b
_params =
  lens (unwrap >>> _.params) (\oldRec newVal -> wrap ((unwrap oldRec) { params = newVal }))

_paymentMethodType :: forall a b c. Newtype a { paymentMethodType :: b | c } => Lens' a b
_paymentMethodType =
  lens (unwrap >>> _.paymentMethodType) (\oldRec newVal -> wrap ((unwrap oldRec) { paymentMethodType = newVal }))

_paymentMethod :: forall a b c. Newtype a { paymentMethod :: b | c } => Lens' a b
_paymentMethod =
  lens (unwrap >>> _.paymentMethod) (\oldRec newVal -> wrap ((unwrap oldRec) { paymentMethod = newVal }))

_voucherCode :: forall a b c. Newtype a { voucherCode :: b | c } => Lens' a b
_voucherCode =
  lens (unwrap >>> _.voucherCode) (\oldRec newVal -> wrap ((unwrap oldRec) { voucherCode = newVal }))

_linked :: forall a b c. Newtype a { linked :: b | c } => Lens' a b
_linked =
  lens (unwrap >>> _.linked) (\oldRec newVal -> wrap ((unwrap oldRec) { linked = newVal }))

_wallet :: forall a b c. Newtype a { wallet :: b | c } => Lens' a b
_wallet =
  lens (unwrap >>> _.wallet) (\oldRec newVal -> wrap ((unwrap oldRec) { wallet = newVal }))

_offerDescription :: forall a b c. Newtype a { offerDescription :: b | c } => Lens' a b
_offerDescription =
  lens (unwrap >>> _.offerDescription) (\oldRec newVal -> wrap ((unwrap oldRec) { offerDescription = newVal }))

_cardToken :: forall a b c. Newtype a { cardToken :: b | c } => Lens' a b
_cardToken =
  lens (unwrap >>> _.cardToken) (\oldRec newVal -> wrap ((unwrap oldRec) { cardToken = newVal }))

_cardType :: forall a b c. Newtype a { cardType :: b | c } => Lens' a b
_cardType =
  lens (unwrap >>> _.cardType) (\oldRec newVal -> wrap ((unwrap oldRec) { cardType = newVal }))