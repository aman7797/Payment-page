module Engineering.Helpers.Types.Accessor where

import Prelude

import Data.Lens (Lens', lens)
import Data.Newtype (class Newtype, unwrap, wrap)

_sdk :: forall a b c. Newtype a {sdk :: c | b} => Lens' a c
_sdk = lens (unwrap >>> _.sdk) (\oldrec newval -> wrap ((unwrap oldrec) {sdk = newval}))

_ppInput :: forall a b c. Newtype a {ppInput :: c | b} => Lens' a c
_ppInput = lens (unwrap >>> _.ppInput) (\oldrec newval -> wrap ((unwrap oldrec) {ppInput = newval}))

_card_token :: forall a b c. Newtype a {card_token :: c | b} => Lens' a c
_card_token = lens (unwrap >>> _.card_token) (\oldrec newval -> wrap ((unwrap oldrec) {card_token = newval}))

_card_reference :: forall a b c. Newtype a {card_reference :: c | b} => Lens' a c
_card_reference = lens (unwrap >>> _.card_reference) (\oldrec newval -> wrap ((unwrap oldrec) {card_reference = newval}))

_masked_card_number :: forall a b c. Newtype a {masked_card_number :: c | b} => Lens' a c
_masked_card_number = lens (unwrap >>> _.masked_card_number) (\oldrec newval -> wrap ((unwrap oldrec) {masked_card_number = newval}))

_card_isin :: forall a b c. Newtype a {card_isin :: c | b} => Lens' a c
_card_isin = lens (unwrap >>> _.card_isin) (\oldrec newval -> wrap ((unwrap oldrec) {card_isin = newval}))

_card_exp_year :: forall a b c. Newtype a {card_exp_year :: c | b} => Lens' a c
_card_exp_year = lens (unwrap >>> _.card_exp_year) (\oldrec newval -> wrap ((unwrap oldrec) {card_exp_year = newval}))

_payment_due_date :: forall a b c. Newtype a {payment_due_date :: c | b} => Lens' a c
_payment_due_date = lens (unwrap >>> _.payment_due_date) (\oldrec newval -> wrap ((unwrap oldrec) {payment_due_date = newval}))

_card_issuer :: forall a b c. Newtype a {card_issuer :: c | b} => Lens' a c
_card_issuer = lens (unwrap >>> _.card_issuer) (\oldrec newval -> wrap ((unwrap oldrec) {card_issuer = newval}))

_minimum_amount :: forall a b c. Newtype a {minimum_amount :: c | b} => Lens' a c
_minimum_amount = lens (unwrap >>> _.minimum_amount) (\oldrec newval -> wrap ((unwrap oldrec) {minimum_amount = newval}))

_custom_amount :: forall a b c. Newtype a {custom_amount :: c | b} => Lens' a c
_custom_amount = lens (unwrap >>> _.custom_amount) (\oldrec newval -> wrap ((unwrap oldrec) {custom_amount = newval}))

_card_exp_month :: forall a b c. Newtype a {card_exp_month :: c | b} => Lens' a c
_card_exp_month = lens (unwrap >>> _.card_exp_month) (\oldrec newval -> wrap ((unwrap oldrec) {card_exp_month = newval}))

_card_type :: forall a b c. Newtype a {card_type :: c | b} => Lens' a c
_card_type = lens (unwrap >>> _.card_type) (\oldrec newval -> wrap ((unwrap oldrec) {card_type = newval}))

_card_brand :: forall a b c. Newtype a {card_brand :: c | b} => Lens' a c
_card_brand = lens (unwrap >>> _.card_brand) (\oldrec newval -> wrap ((unwrap oldrec) {card_brand = newval}))

_name_on_card :: forall a b c. Newtype a {name_on_card :: c | b} => Lens' a c
_name_on_card = lens (unwrap >>> _.name_on_card) (\oldrec newval -> wrap ((unwrap oldrec) {name_on_card = newval}))

_expired :: forall a b c. Newtype a {expired :: c | b} => Lens' a c
_expired = lens (unwrap >>> _.expired) (\oldrec newval -> wrap ((unwrap oldrec) {expired = newval}))

_customer_id :: forall a b c. Newtype a {customer_id :: c | b} => Lens' a c
_customer_id = lens (unwrap >>> _.customer_id) (\oldrec newval -> wrap ((unwrap oldrec) {customer_id = newval}))

_card_fingerprint :: forall a b c. Newtype a {card_fingerprint :: c | b} => Lens' a c
_card_fingerprint = lens (unwrap >>> _.card_fingerprint) (\oldrec newval -> wrap ((unwrap oldrec) {card_fingerprint = newval}))

_merchantId :: forall a b c. Newtype a {merchantId :: c | b} => Lens' a c
_merchantId = lens (unwrap >>> _.merchantId) (\oldrec newval -> wrap ((unwrap oldrec) {merchantId = newval}))

_order_id :: forall a b c. Newtype a {order_id :: c | b} => Lens' a c
_order_id = lens (unwrap >>> _.order_id) (\oldrec newval -> wrap ((unwrap oldrec) {order_id = newval}))

_merchant_id :: forall a b c. Newtype a {merchant_id :: c | b} => Lens' a c
_merchant_id = lens (unwrap >>> _.merchant_id) (\oldrec newval -> wrap ((unwrap oldrec) {merchant_id = newval}))

_payment_method_type :: forall a b c. Newtype a {payment_method_type :: c | b} => Lens' a c
_payment_method_type = lens (unwrap >>> _.payment_method_type) (\oldrec newval -> wrap ((unwrap oldrec) {payment_method_type = newval}))

_payment_method :: forall a b c. Newtype a {payment_method :: c | b} => Lens' a c
_payment_method = lens (unwrap >>> _.payment_method) (\oldrec newval -> wrap ((unwrap oldrec) {payment_method = newval}))

_card_security_code :: forall a b c. Newtype a {card_security_code :: c | b} => Lens' a c
_card_security_code = lens (unwrap >>> _.card_security_code) (\oldrec newval -> wrap ((unwrap oldrec) {card_security_code = newval}))

_save_to_locker :: forall a b c. Newtype a {save_to_locker :: c | b} => Lens' a c
_save_to_locker = lens (unwrap >>> _.save_to_locker) (\oldrec newval -> wrap ((unwrap oldrec) {save_to_locker = newval}))

_redirect_after_payment :: forall a b c. Newtype a {redirect_after_payment :: c | b} => Lens' a c
_redirect_after_payment = lens (unwrap >>> _.redirect_after_payment) (\oldrec newval -> wrap ((unwrap oldrec) {redirect_after_payment = newval}))

_format :: forall a b c. Newtype a {format :: c | b} => Lens' a c
_format = lens (unwrap >>> _.format) (\oldrec newval -> wrap ((unwrap oldrec) {format = newval}))

_method :: forall a b c. Newtype a {method :: c | b} => Lens' a c
_method = lens (unwrap >>> _.method) (\oldrec newval -> wrap ((unwrap oldrec) {method = newval}))

_url :: forall a b c. Newtype a {url :: c | b} => Lens' a c
_url = lens (unwrap >>> _.url) (\oldrec newval -> wrap ((unwrap oldrec) {url = newval}))

_authentication :: forall a b c. Newtype a {authentication :: c | b} => Lens' a c
_authentication = lens (unwrap >>> _.authentication) (\oldrec newval -> wrap ((unwrap oldrec) {authentication = newval}))

_txn_id :: forall a b c. Newtype a {txn_id :: c | b} => Lens' a c
_txn_id = lens (unwrap >>> _.txn_id) (\oldrec newval -> wrap ((unwrap oldrec) {txn_id = newval}))

_txn_uuid :: forall a b c. Newtype a {txn_uuid :: c | b} => Lens' a c
_txn_uuid = lens (unwrap >>> _.txn_uuid) (\oldrec newval -> wrap ((unwrap oldrec) {txn_uuid = newval}))

_status :: forall a b c. Newtype a {status :: c | b} => Lens' a c
_status = lens (unwrap >>> _.status) (\oldrec newval -> wrap ((unwrap oldrec) {status = newval}))

_payment :: forall a b c. Newtype a {payment :: c | b} => Lens' a c
_payment = lens (unwrap >>> _.payment) (\oldrec newval -> wrap ((unwrap oldrec) {payment = newval}))

_auth_type :: forall a b c. Newtype a {auth_type :: c | b} => Lens' a c
_auth_type = lens (unwrap >>> _.auth_type) (\oldrec newval -> wrap ((unwrap oldrec) {auth_type = newval}))

_direct_wallet_token :: forall a b c. Newtype a {direct_wallet_token :: c | b} => Lens' a c
_direct_wallet_token = lens (unwrap >>> _.direct_wallet_token) (\oldrec newval -> wrap ((unwrap oldrec) {direct_wallet_token = newval}))

_command :: forall a b c. Newtype a {command :: c | b} => Lens' a c
_command = lens (unwrap >>> _.command) (\oldrec newval -> wrap ((unwrap oldrec) {command = newval}))

_id :: forall a b c. Newtype a {id :: c | b} => Lens' a c
_id = lens (unwrap >>> _.id) (\oldrec newval -> wrap ((unwrap oldrec) {id = newval}))

_object :: forall a b c. Newtype a {object :: c | b} => Lens' a c
_object = lens (unwrap >>> _.object) (\oldrec newval -> wrap ((unwrap oldrec) {object = newval}))

_wallet :: forall a b c. Newtype a {wallet :: c | b} => Lens' a c
_wallet = lens (unwrap >>> _.wallet) (\oldrec newval -> wrap ((unwrap oldrec) {wallet = newval}))

_current_balance :: forall a b c. Newtype a {current_balance :: c | b} => Lens' a c
_current_balance = lens (unwrap >>> _.current_balance) (\oldrec newval -> wrap ((unwrap oldrec) {current_balance = newval}))

_token :: forall a b c. Newtype a {token :: c | b} => Lens' a c
_token = lens (unwrap >>> _.token) (\oldrec newval -> wrap ((unwrap oldrec) {token = newval}))

_linked :: forall a b c. Newtype a {linked :: c | b} => Lens' a c
_linked = lens (unwrap >>> _.linked) (\oldrec newval -> wrap ((unwrap oldrec) {linked = newval}))

_last_refreshed :: forall a b c. Newtype a {last_refreshed :: c | b} => Lens' a c
_last_refreshed = lens (unwrap >>> _.last_refreshed) (\oldrec newval -> wrap ((unwrap oldrec) {last_refreshed = newval}))

_otp :: forall a b c. Newtype a {otp :: c | b} => Lens' a c
_otp = lens (unwrap >>> _.otp) (\oldrec newval -> wrap ((unwrap oldrec) {otp = newval}))

_list :: forall a b c. Newtype a {list :: c | b} => Lens' a c
_list = lens (unwrap >>> _.list) (\oldrec newval -> wrap ((unwrap oldrec) {list = newval}))

_offset :: forall a b c. Newtype a {offset :: c | b} => Lens' a c
_offset = lens (unwrap >>> _.offset) (\oldrec newval -> wrap ((unwrap oldrec) {offset = newval}))

_total :: forall a b c. Newtype a {total :: c | b} => Lens' a c
_total = lens (unwrap >>> _.total) (\oldrec newval -> wrap ((unwrap oldrec) {total = newval}))

_count :: forall a b c. Newtype a {count :: c | b} => Lens' a c
_count = lens (unwrap >>> _.count) (\oldrec newval -> wrap ((unwrap oldrec) {count = newval}))

_currentDebitCardIndex :: forall a b c. Newtype a {currentDebitCardIndex  :: c | b} => Lens' a c
_currentDebitCardIndex = lens (unwrap >>> _.currentDebitCardIndex) (\oldrec newval -> wrap ((unwrap oldrec) {currentDebitCardIndex = newval}))

_amount :: forall a b c. Newtype a {amount :: c | b} => Lens' a c
_amount = lens (unwrap >>> _.amount) (\oldrec newval -> wrap ((unwrap oldrec) {amount = newval}))

_maxAmount :: forall a b c. Newtype a {maxAmount :: c | b} => Lens' a c
_maxAmount = lens (unwrap >>> _.maxAmount) (\oldrec newval -> wrap ((unwrap oldrec) {maxAmount = newval}))

_minAmount :: forall a b c. Newtype a {minAmount :: c | b} => Lens' a c
_minAmount = lens (unwrap >>> _.minAmount) (\oldrec newval -> wrap ((unwrap oldrec) {minAmount = newval}))

_topup_txn_id :: forall a b c. Newtype a {topup_txn_id :: c | b} => Lens' a c
_topup_txn_id = lens (unwrap >>> _.topup_txn_id) (\oldrec newval -> wrap ((unwrap oldrec) {topup_txn_id = newval}))

_return_url :: forall a b c. Newtype a {return_url :: c | b} => Lens' a c
_return_url = lens (unwrap >>> _.return_url) (\oldrec newval -> wrap ((unwrap oldrec) {return_url = newval}))

_wallet_id :: forall a b c. Newtype a {wallet_id :: c | b} => Lens' a c
_wallet_id = lens (unwrap >>> _.wallet_id) (\oldrec newval -> wrap ((unwrap oldrec) {wallet_id = newval}))

_payment_url :: forall a b c. Newtype a {payment_url :: c | b} => Lens' a c
_payment_url = lens (unwrap >>> _.payment_url) (\oldrec newval -> wrap ((unwrap oldrec) {payment_url = newval}))

_order_token :: forall a b c. Newtype a {order_token :: c | b} => Lens' a c
_order_token = lens (unwrap >>> _.order_token) (\oldrec newval -> wrap ((unwrap oldrec) {order_token = newval}))

_currentBalance :: forall a b c. Newtype a {currentBalance :: c | b} => Lens' a c
_currentBalance = lens (unwrap >>> _.currentBalance) (\oldrec newval -> wrap ((unwrap oldrec) {currentBalance = newval}))

_lastRefreshed :: forall a b c. Newtype a {lastRefreshed :: c | b} => Lens' a c
_lastRefreshed = lens (unwrap >>> _.lastRefreshed) (\oldrec newval -> wrap ((unwrap oldrec) {lastRefreshed = newval}))

_vpa :: forall a b c. Newtype a {vpa :: c | b} => Lens' a c
_vpa = lens (unwrap >>> _.vpa) (\oldrec newval -> wrap ((unwrap oldrec) {vpa = newval}))

_nickname :: forall a b c. Newtype a {nickname :: c | b} => Lens' a c
_nickname = lens (unwrap >>> _.nickname) (\oldrec newval -> wrap ((unwrap oldrec) {nickname = newval}))

_nameOnCard :: forall a b c. Newtype a {nameOnCard :: c | b} => Lens' a c
_nameOnCard = lens (unwrap >>> _.nameOnCard) (\oldrec newval -> wrap ((unwrap oldrec) {nameOnCard = newval}))

_cardType :: forall a b c. Newtype a {cardType :: c | b} => Lens' a c
_cardType = lens (unwrap >>> _.cardType) (\oldrec newval -> wrap ((unwrap oldrec) {cardType = newval}))

_cardToken :: forall a b c. Newtype a {cardToken :: c | b} => Lens' a c
_cardToken = lens (unwrap >>> _.cardToken) (\oldrec newval -> wrap ((unwrap oldrec) {cardToken = newval}))

_cardReference :: forall a b c. Newtype a {cardReference :: c | b} => Lens' a c
_cardReference = lens (unwrap >>> _.cardReference) (\oldrec newval -> wrap ((unwrap oldrec) {cardReference = newval}))

_cardIssuer :: forall a b c. Newtype a {cardIssuer :: c | b} => Lens' a c
_cardIssuer = lens (unwrap >>> _.cardIssuer) (\oldrec newval -> wrap ((unwrap oldrec) {cardIssuer = newval}))

_cardIsin :: forall a b c. Newtype a {cardIsin :: c | b} => Lens' a c
_cardIsin = lens (unwrap >>> _.cardIsin) (\oldrec newval -> wrap ((unwrap oldrec) {cardIsin = newval}))

_cardFingerprint :: forall a b c. Newtype a {cardFingerprint :: c | b} => Lens' a c
_cardFingerprint = lens (unwrap >>> _.cardFingerprint) (\oldrec newval -> wrap ((unwrap oldrec) {cardFingerprint = newval}))

_cardExpYear :: forall a b c. Newtype a {cardExpYear :: c | b} => Lens' a c
_cardExpYear = lens (unwrap >>> _.cardExpYear) (\oldrec newval -> wrap ((unwrap oldrec) {cardExpYear = newval}))

_cardExpMonth :: forall a b c. Newtype a {cardExpMonth :: c | b} => Lens' a c
_cardExpMonth = lens (unwrap >>> _.cardExpMonth) (\oldrec newval -> wrap ((unwrap oldrec) {cardExpMonth = newval}))

_cardBrand :: forall a b c. Newtype a {cardBrand :: c | b} => Lens' a c
_cardBrand = lens (unwrap >>> _.cardBrand) (\oldrec newval -> wrap ((unwrap oldrec) {cardBrand = newval}))

_paymentMethodType :: forall a b c. Newtype a {paymentMethodType :: c | b} => Lens' a c
_paymentMethodType = lens (unwrap >>> _.paymentMethodType) (\oldrec newval -> wrap ((unwrap oldrec) {paymentMethodType = newval}))

_paymentMethod :: forall a b c. Newtype a {paymentMethod :: c | b} => Lens' a c
_paymentMethod = lens (unwrap >>> _.paymentMethod) (\oldrec newval -> wrap ((unwrap oldrec) {paymentMethod = newval}))

_description :: forall a b c. Newtype a {description :: c | b} => Lens' a c
_description = lens (unwrap >>> _.description) (\oldrec newval -> wrap ((unwrap oldrec) {description = newval}))

_wallets :: forall a b c. Newtype a {wallets :: c | b} => Lens' a c
_wallets = lens (unwrap >>> _.wallets) (\oldrec newval -> wrap ((unwrap oldrec) {wallets = newval}))

_vpas :: forall a b c. Newtype a {vpas :: c | b} => Lens' a c
_vpas = lens (unwrap >>> _.vpas) (\oldrec newval -> wrap ((unwrap oldrec) {vpas = newval}))

_nbMethods :: forall a b c. Newtype a {nbMethods :: c | b} => Lens' a c
_nbMethods = lens (unwrap >>> _.nbMethods) (\oldrec newval -> wrap ((unwrap oldrec) {nbMethods = newval}))

_cards :: forall a b c. Newtype a {cards :: c | b} => Lens' a c
_cards = lens (unwrap >>> _.cards) (\oldrec newval -> wrap ((unwrap oldrec) {cards = newval}))

_lastUsedPaymentMethod :: forall a b c. Newtype a {lastUsedPaymentMethod :: c | b} => Lens' a c
_lastUsedPaymentMethod = lens (unwrap >>> _.lastUsedPaymentMethod) (\oldrec newval -> wrap ((unwrap oldrec) {lastUsedPaymentMethod = newval}))

_merchantPaymentMethods :: forall a b c. Newtype a {merchantPaymentMethods :: c | b} => Lens' a c
_merchantPaymentMethods = lens (unwrap >>> _.merchantPaymentMethods) (\oldrec newval -> wrap ((unwrap oldrec) {merchantPaymentMethods = newval}))

_customerMobile :: forall a b c. Newtype a { customerMobile :: c | b} => Lens' a c
_customerMobile = lens (unwrap >>> _.customerMobile) (\oldrec newval -> wrap ((unwrap oldrec) { customerMobile = newval}))

_customerId :: forall a b c. Newtype a { customerId :: c | b} => Lens' a c
_customerId = lens (unwrap >>> _.customerId) (\oldrec newval -> wrap ((unwrap oldrec) { customerId = newval}))

_orderId :: forall a b c. Newtype a { orderId :: c | b} => Lens' a c
_orderId = lens (unwrap >>> _.orderId) (\oldrec newval -> wrap ((unwrap oldrec) { orderId = newval}))

_orderToken :: forall a b c. Newtype a { orderToken :: c | b} => Lens' a c
_orderToken = lens (unwrap >>> _.orderToken) (\oldrec newval -> wrap ((unwrap oldrec) { orderToken = newval}))

_clientId :: forall a b c. Newtype a { clientId :: c | b} => Lens' a c
_clientId = lens (unwrap >>> _.clientId) (\oldrec newval -> wrap ((unwrap oldrec) { clientId = newval}))

_renderCount :: forall a b c. Newtype a { renderCount :: c | b} => Lens' a c
_renderCount = lens (unwrap >>> _.renderCount) (\oldrec newval -> wrap ((unwrap oldrec) { renderCount = newval}))

_itemCount :: forall a b c. Newtype a { itemCount :: c | b} => Lens' a c
_itemCount = lens (unwrap >>> _.itemCount) (\oldrec newval -> wrap ((unwrap oldrec) { itemCount = newval}))

_offerCode :: forall a b c. Newtype a { offerCode :: c | b} => Lens' a c
_offerCode = lens (unwrap >>> _.offerCode) (\oldrec newval -> wrap ((unwrap oldrec) { offerCode = newval}))

_cashEnabled :: forall a b c. Newtype a { cashEnabled :: c | b} => Lens' a c
_cashEnabled = lens (unwrap >>> _.cashEnabled) (\oldrec newval -> wrap ((unwrap oldrec) { cashEnabled = newval}))

_isSelected :: forall a b c. Newtype a { isSelected :: c | b} => Lens' a c
_isSelected = lens (unwrap >>> _.isSelected) (\oldrec newval -> wrap ((unwrap oldrec) { isSelected = newval}))

_details :: forall a b c. Newtype a { details :: c | b} => Lens' a c
_details = lens (unwrap >>> _.details) (\oldrec newval -> wrap ((unwrap oldrec) { details = newval}))

_isPayloadRefreshed :: forall a b c. Newtype a { isPayloadRefreshed :: c | b} => Lens' a c
_isPayloadRefreshed = lens (unwrap >>> _.isPayloadRefreshed) (\oldrec newval -> wrap ((unwrap oldrec) { isPayloadRefreshed = newval}))

_listState :: forall a b c. Newtype a { listState :: c | b} => Lens' a c
_listState = lens (unwrap >>> _.listState) (\oldrec newval -> wrap ((unwrap oldrec) { listState = newval}))

_selectedItem :: forall a b c. Newtype a { selectedItem :: c | b} => Lens' a c
_selectedItem = lens (unwrap >>> _.selectedItem) (\oldrec newval -> wrap ((unwrap oldrec) { selectedItem = newval }))

_piInfo :: forall a b c. Newtype a { piInfo :: c | b} => Lens' a c
_piInfo = lens (unwrap >>> _.piInfo) (\oldrec newval -> wrap ((unwrap oldrec) { piInfo = newval }))

_uiState :: forall a b c. Newtype a { uiState :: c | b} => Lens' a c
_uiState = lens (unwrap >>> _.uiState) (\oldrec newval -> wrap ((unwrap oldrec) { uiState = newval }))

_addNewCardState :: forall a b c. Newtype a { addNewCardState :: c | b} => Lens' a c
_addNewCardState = lens (unwrap >>> _.addNewCardState) (\oldrec newval -> wrap ((unwrap oldrec) { addNewCardState = newval }))

_amountEditOverlay :: forall a b c. Newtype a { amountEditOverlay :: c | b} => Lens' a c
_amountEditOverlay = lens (unwrap >>> _.amountEditOverlay) (\oldrec newval -> wrap ((unwrap oldrec) { amountEditOverlay = newval }))

_storedCards :: forall a b c. Newtype a { storedCards :: c | b} => Lens' a c
_storedCards = lens (unwrap >>> _.storedCards) (\oldrec newval -> wrap ((unwrap oldrec) { storedCards = newval }))

_scroll :: forall a b c. Newtype a { scroll :: c | b} => Lens' a c
_scroll = lens (unwrap >>> _.scroll) (\oldrec newval -> wrap ((unwrap oldrec) { scroll = newval }))

_billerCard :: forall a b c. Newtype a { billerCard :: c | b} => Lens' a c
_billerCard = lens (unwrap >>> _.billerCard) (\oldrec newval -> wrap ((unwrap oldrec) { billerCard = newval }))

_proceedButtonState :: forall a b c. Newtype a { proceedButtonState :: c | b} => Lens' a c
_proceedButtonState = lens (unwrap >>> _.proceedButtonState) (\oldrec newval -> wrap ((unwrap oldrec) { proceedButtonState = newval }))

_supportedMethods :: forall a b c. Newtype a { supportedMethods :: c | b} => Lens' a c
_supportedMethods = lens (unwrap >>> _.supportedMethods) (\oldrec newval -> wrap ((unwrap oldrec) { supportedMethods = newval }))

_cardMethod :: forall a b c. Newtype a { cardMethod :: c | b} => Lens' a c
_cardMethod = lens (unwrap >>> _.cardMethod) (\oldrec newval -> wrap ((unwrap oldrec) { cardMethod = newval }))

_currentFocused :: forall a b c. Newtype a { currentFocused :: c | b} => Lens' a c
_currentFocused = lens (unwrap >>> _.currentFocused) (\oldrec newval -> wrap ((unwrap oldrec) { currentFocused = newval }))

_cardNumber :: forall a b c. Newtype a { cardNumber :: c | b} => Lens' a c
_cardNumber = lens (unwrap >>> _.cardNumber) (\oldrec newval -> wrap ((unwrap oldrec) { cardNumber = newval }))

_value :: forall a b c. Newtype a { value :: c | b} => Lens' a c
_value = lens (unwrap >>> _.value) (\oldrec newval -> wrap ((unwrap oldrec) { value = newval }))

_card_details :: forall a b c. Newtype a { card_details :: c | b} => Lens' a c
_card_details = lens (unwrap >>> _.card_details) (\oldrec newval -> wrap ((unwrap oldrec) { card_details = newval }))


_expiryDate :: forall a b c. Newtype a { expiryDate :: c | b} => Lens' a c
_expiryDate = lens (unwrap >>> _.expiryDate) (\oldrec newval -> wrap ((unwrap oldrec) { expiryDate = newval }))

_lastSixNumber :: forall a b c. Newtype a { lastSixNumber :: c | b} => Lens' a c
_lastSixNumber = lens (unwrap >>> _.lastSixNumber) (\oldrec newval -> wrap ((unwrap oldrec) { lastSixNumber = newval }))

_cvv :: forall a b c. Newtype a { cvv :: c | b} => Lens' a c
_cvv = lens (unwrap >>> _.cvv) (\oldrec newval -> wrap ((unwrap oldrec) { cvv = newval }))

_supported_lengths :: forall a b c. Newtype a { supported_lengths :: c | b} => Lens' a c
_supported_lengths = lens (unwrap >>> _.supported_lengths) (\oldrec newval -> wrap ((unwrap oldrec) { supported_lengths = newval }))

_luhn_valid :: forall a b c. Newtype a { luhn_valid :: c | b} => Lens' a c
_luhn_valid = lens (unwrap >>> _.luhn_valid) (\oldrec newval -> wrap ((unwrap oldrec) { luhn_valid = newval }))

_savedForLater :: forall a b c. Newtype a { savedForLater :: c | b} => Lens' a c
_savedForLater = lens (unwrap >>> _.savedForLater) (\oldrec newval -> wrap ((unwrap oldrec) { savedForLater = newval }))

_formState :: forall a b c. Newtype a { formState :: c | b} => Lens' a c
_formState = lens (unwrap >>> _.formState) (\oldrec newval -> wrap ((unwrap oldrec) { formState = newval }))

_currentOverlay :: forall a b c. Newtype a { currentOverlay :: c | b} => Lens' a c
_currentOverlay = lens (unwrap >>> _.currentOverlay) (\oldrec newval -> wrap ((unwrap oldrec) { currentOverlay = newval }))

_sections :: forall a b c. Newtype a { sections :: c | b} => Lens' a c
_sections = lens (unwrap >>> _.sections) (\oldrec newval -> wrap ((unwrap oldrec) { sections = newval }))

_screenWidth :: forall a b c. Newtype a { screenWidth :: c | b} => Lens' a c
_screenWidth = lens (unwrap >>> _.screenWidth) (\oldrec newval -> wrap ((unwrap oldrec) { screenWidth = newval }))

_renderType :: forall a b c. Newtype a { renderType :: c | b} => Lens' a c
_renderType = lens (unwrap >>> _.renderType) (\oldrec newval -> wrap ((unwrap oldrec) { renderType = newval }))



_sectionSelected :: forall a b c. Newtype a { sectionSelected :: c | b} => Lens' a c
_sectionSelected = lens (unwrap >>> _.sectionSelected) (\oldrec newval -> wrap ((unwrap oldrec) { sectionSelected = newval }))

_nbListState :: forall a b c. Newtype a { nbListState :: c | b} => Lens' a c
_nbListState = lens (unwrap >>> _.nbListState) (\oldrec newval -> wrap ((unwrap oldrec) { nbListState = newval }))

_upiNBTabState :: forall a b c. Newtype a { upiNBTabState :: c | b} => Lens' a c
_upiNBTabState = lens (unwrap >>> _.upiNBTabState) (\oldrec newval -> wrap ((unwrap oldrec) { upiNBTabState = newval }))

_nbGrid :: forall a b c. Newtype a { nbGrid :: c | b} => Lens' a c
_nbGrid = lens (unwrap >>> _.nbGrid) (\oldrec newval -> wrap ((unwrap oldrec) { nbGrid = newval }))

_code :: forall a b c. Newtype a { code :: c | b} => Lens' a c
_code = lens (unwrap >>> _.code) (\oldrec newval -> wrap ((unwrap oldrec) { code = newval }))

_name :: forall a b c. Newtype a { name :: c | b} => Lens' a c
_name = lens (unwrap >>> _.name) (\oldrec newval -> wrap ((unwrap oldrec) { name = newval }))

_bankCode :: forall a b c. Newtype a { bankCode :: c | b} => Lens' a c
_bankCode = lens (unwrap >>> _.bankCode) (\oldrec newval -> wrap ((unwrap oldrec) { bankCode = newval }))

_bankName :: forall a b c. Newtype a { bankName :: c | b} => Lens' a c
_bankName = lens (unwrap >>> _.bankName) (\oldrec newval -> wrap ((unwrap oldrec) { bankName = newval }))

_items :: forall a b c. Newtype a { items :: c | b} => Lens' a c
_items = lens (unwrap >>> _.items) (\oldrec newval -> wrap ((unwrap oldrec) { items = newval }))

_orderInfo :: forall a b c. Newtype a { orderInfo :: c | b} => Lens' a c
_orderInfo = lens (unwrap >>> _.orderInfo) (\oldrec newval -> wrap ((unwrap oldrec) { orderInfo = newval }))

_error :: forall a b c. Newtype a { error :: c | b} => Lens' a c
_error = lens (unwrap >>> _.error) (\oldrec newval -> wrap ((unwrap oldrec) { error = newval }))

_response :: forall a b c. Newtype a { response :: c | b} => Lens' a c
_response = lens (unwrap >>> _.response) (\oldrec newval -> wrap ((unwrap oldrec) { response = newval }))

_currentSelected :: forall a b c. Newtype a { currentSelected :: c | b} => Lens' a c
_currentSelected = lens (unwrap >>> _.currentSelected) (\oldrec newval -> wrap ((unwrap oldrec) { currentSelected = newval }))

_currentIndex :: forall a b c. Newtype a { currentIndex :: c | b} => Lens' a c
_currentIndex = lens (unwrap >>> _.currentIndex) (\oldrec newval -> wrap ((unwrap oldrec) { currentIndex = newval }))

_card_ref :: forall a b c. Newtype a { card_ref :: c | b} => Lens' a c
_card_ref = lens (unwrap >>> _.card_ref) (\oldrec newval -> wrap ((unwrap oldrec) { card_ref = newval }))

_fullfilment :: forall a b c. Newtype a { fullfilment :: c | b} => Lens' a c
_fullfilment = lens (unwrap >>> _.fullfilment) (\oldrec newval -> wrap ((unwrap oldrec) { fullfilment = newval }))

_preferedBanks :: forall a b c. Newtype a { preferedBanks :: c | b} => Lens' a c
_preferedBanks = lens (unwrap >>> _.preferedBanks) (\oldrec newval -> wrap ((unwrap oldrec) { preferedBanks = newval }))

_message :: forall a b c. Newtype a { message :: c | b} => Lens' a c
_message = lens (unwrap >>> _.message) (\oldrec newval -> wrap ((unwrap oldrec) {message = newval }))

_message_color :: forall a b c. Newtype a { message_color :: c | b} => Lens' a c
_message_color = lens (unwrap >>> _.message_color) (\oldrec newval -> wrap ((unwrap oldrec) {message_color = newval }))


_card_editable :: forall a b c. Newtype a { card_editable :: c | b} => Lens' a c
_card_editable = lens (unwrap >>> _.card_editable) (\oldrec newval -> wrap ((unwrap oldrec) { card_editable = newval }))


_billerCardEditable :: forall a b c. Newtype a { billerCardEditable :: c | b} => Lens' a c
_billerCardEditable = lens (unwrap >>> _.billerCardEditable) (\oldrec newval -> wrap ((unwrap oldrec) { billerCardEditable = newval }))

_upiApps :: forall a b c. Newtype a { upiApps :: c | b} => Lens' a c
_upiApps = lens (unwrap >>> _.upiApps) (\oldrec newval -> wrap ((unwrap oldrec) { upiApps = newval }))

_upiInfo :: forall a b c. Newtype a { upiInfo :: c | b} => Lens' a c
_upiInfo = lens (unwrap >>> _.upiInfo) (\oldrec newval -> wrap ((unwrap oldrec) { upiInfo = newval }))

_amount_payable :: forall a b c. Newtype a { amount_payable :: c | b} => Lens' a c
_amount_payable = lens (unwrap >>> _.amount_payable) (\oldrec newval -> wrap ((unwrap oldrec) { amount_payable = newval }))

_total_amount :: forall a b c. Newtype a { total_amount :: c | b} => Lens' a c
_total_amount = lens (unwrap >>> _.total_amount) (\oldrec newval -> wrap ((unwrap oldrec) { total_amount = newval }))

_available_apps :: forall a b c. Newtype a { available_apps :: c | b} => Lens' a c
_available_apps = lens (unwrap >>> _.available_apps) (\oldrec newval -> wrap ((unwrap oldrec) { available_apps = newval }))

_apps :: forall a b c. Newtype a { apps :: c | b} => Lens' a c
_apps = lens (unwrap >>> _.apps) (\oldrec newval -> wrap ((unwrap oldrec) { apps = newval }))

_updatedBillercardArray :: forall a b c. Newtype a { updatedBillercardArray :: c | b} => Lens' a c
_updatedBillercardArray = lens (unwrap >>> _.updatedBillercardArray) (\oldrec newval -> wrap ((unwrap oldrec) { updatedBillercardArray = newval }))

_cardDetails :: forall a b c. Newtype a { cardDetails :: c | b} => Lens' a c
_cardDetails = lens (unwrap >>> _.cardDetails) (\oldrec newval -> wrap ((unwrap oldrec) { cardDetails = newval }))

_button1State :: forall a b c. Newtype a {button1State :: c | b} => Lens' a c
_button1State = lens (unwrap >>> _.button1State) (\oldRec newVal -> wrap ((unwrap oldRec) {button1State = newVal}))

_uiType :: forall a b c. Newtype a { uiType :: c | b} => Lens' a c
_uiType = lens (unwrap >>> _.uiType) (\oldrec newval -> wrap ((unwrap oldrec) { uiType = newval }))

_userMessage :: forall a b c. Newtype a { userMessage :: c | b} => Lens' a c
_userMessage = lens (unwrap >>> _.userMessage) (\oldrec newval -> wrap ((unwrap oldrec) { userMessage = newval }))

_currentScrollPostion :: forall a b c. Newtype a { currentScrollPostion :: c | b} => Lens' a c
_currentScrollPostion = lens (unwrap >>> _.currentScrollPostion) (\oldrec newval -> wrap ((unwrap oldrec) { currentScrollPostion = newval }))

_upiTabState :: forall a b c. Newtype a { upiTabState :: c | b} => Lens' a c
_upiTabState = lens (unwrap >>> _.upiTabState) (\oldrec newval -> wrap ((unwrap oldrec) { upiTabState = newval }))

_setUpiPinState :: forall a b c. Newtype a { setUpiPinState :: c | b} => Lens' a c
_setUpiPinState = lens (unwrap >>> _.setUpiPinState) (\oldrec newval -> wrap ((unwrap oldrec) { setUpiPinState = newval }))

_cvvOverlayState :: forall a b c. Newtype a { cvvOverlayState :: c | b} => Lens' a c
_cvvOverlayState = lens (unwrap >>> _.cvvOverlayState) (\oldrec newval -> wrap ((unwrap oldrec) { cvvOverlayState = newval }))

_selectBankState :: forall a b c. Newtype a { selectBankState :: c | b} => Lens' a c
_selectBankState = lens (unwrap >>> _.selectBankState) (\oldrec newval -> wrap ((unwrap oldrec) { selectBankState = newval }))

_scrollToPosition :: forall a b c. Newtype a { scrollToPosition :: c | b} => Lens' a c
_scrollToPosition = lens (unwrap >>> _.scrollToPosition) (\oldrec newval -> wrap ((unwrap oldrec) { scrollToPosition = newval }))

_cvvFocusIndex :: forall a b c. Newtype a { cvvFocusIndex :: c | b} => Lens' a c
_cvvFocusIndex = lens (unwrap >>> _.cvvFocusIndex) (\oldrec newval -> wrap ((unwrap oldrec) { cvvFocusIndex = newval }))

_upiAccounts :: forall a b c. Newtype a { upiAccounts :: c | b} => Lens' a c
_upiAccounts = lens (unwrap >>> _.upiAccounts) (\oldrec newval -> wrap ((unwrap oldrec) { upiAccounts = newval }))

_enteredValue :: forall a b c. Newtype a { entered_value :: c | b} => Lens' a c
_enteredValue = lens (unwrap >>> _.entered_value) (\oldrec newval -> wrap ((unwrap oldrec) { entered_value = newval }))

_youPay :: forall a b c. Newtype a { you_pay :: c | b} => Lens' a c
_youPay = lens (unwrap >>> _.you_pay) (\oldrec newval -> wrap ((unwrap oldrec) { you_pay = newval }))

_dueIn :: forall a b c. Newtype a { due_in :: c | b} => Lens' a c
_dueIn = lens (unwrap >>> _.due_in) (\oldrec newval -> wrap ((unwrap oldrec) { due_in = newval }))

_payTotal :: forall a b c. Newtype a { pay_total :: c | b} => Lens' a c
_payTotal = lens (unwrap >>> _.pay_total) (\oldrec newval -> wrap ((unwrap oldrec) { pay_total = newval }))

_bank_Name :: forall a b c. Newtype a { bank_name :: c | b} => Lens' a c
_bank_Name = lens (unwrap >>> _.bank_name) (\oldrec newval -> wrap ((unwrap oldrec) { bank_name = newval }))

_upiViewState :: forall a b c. Newtype a { upiViewState :: c | b} => Lens' a c
_upiViewState = lens (unwrap >>> _.upiViewState) (\oldrec newval -> wrap ((unwrap oldrec) { upiViewState = newval }))



_cardProvider :: forall a b c. Newtype a { card_provider :: c | b} => Lens' a c
_cardProvider = lens (unwrap >>> _.card_provider) (\oldrec newval -> wrap ((unwrap oldrec) { card_provider = newval }))

_payUsing :: forall a b c. Newtype a { pay_using :: c | b} => Lens' a c
_payUsing = lens (unwrap >>> _.pay_using) (\oldrec newval -> wrap ((unwrap oldrec) { pay_using = newval }))

_totalAmount :: forall a b c. Newtype a { total_amount :: c | b} => Lens' a c
_totalAmount = lens (unwrap >>> _.total_amount) (\oldrec newval -> wrap ((unwrap oldrec) { total_amount = newval }))

_totalMin :: forall a b c. Newtype a { total_min :: c | b} => Lens' a c
_totalMin = lens (unwrap >>> _.total_min) (\oldrec newval -> wrap ((unwrap oldrec) { total_min = newval }))
 
_totalCustom :: forall a b c. Newtype a { total_custom :: c | b} => Lens' a c
_totalCustom = lens (unwrap >>> _.total_custom) (\oldrec newval -> wrap ((unwrap oldrec) { total_custom = newval }))

_selectedBank :: forall a b c. Newtype a { selected_debit_card_bank_name :: c | b} => Lens' a c
_selectedBank = lens (unwrap >>> _.selected_debit_card_bank_name) (\oldrec newval -> wrap ((unwrap oldrec) { selected_debit_card_bank_name = newval }))

_selectedProvider :: forall a b c. Newtype a { selected_debit_card_provider :: c | b} => Lens' a c
_selectedProvider = lens (unwrap >>> _.selected_debit_card_provider) (\oldrec newval -> wrap ((unwrap oldrec) { selected_debit_card_provider = newval }))

_debitCardCount :: forall a b c. Newtype a { debit_card_count :: c | b} => Lens' a c
_debitCardCount = lens (unwrap >>> _.debit_card_count) (\oldrec newval -> wrap ((unwrap oldrec) { debit_card_count = newval }))

_isFocused :: forall a b c. Newtype a { isFocused :: c | b} => Lens' a c
_isFocused = lens (unwrap >>> _.isFocused) (\oldrec newval -> wrap ((unwrap oldrec) { isFocused = newval }))

_session_token :: forall a b c. Newtype a { session_token :: c | b} => Lens' a c
_session_token = lens (unwrap >>> _.session_token) (\oldrec newval -> wrap ((unwrap oldrec) { session_token = newval }))

_sims :: forall a b c. Newtype a { sims :: c | b} => Lens' a c
_sims = lens (unwrap >>> _.sims) (\oldrec newval -> wrap ((unwrap oldrec) { sims = newval }))

_carrierName :: forall a b c. Newtype a { carrierName :: c | b} => Lens' a c
_carrierName = lens (unwrap >>> _.carrierName) (\oldrec newval -> wrap ((unwrap oldrec) { carrierName = newval }))

_register :: forall a b c. Newtype a { register :: c | b} => Lens' a c
_register = lens (unwrap >>> _.register) (\oldrec newval -> wrap ((unwrap oldrec) { register = newval }))

_mpinSet :: forall a b c. Newtype a { mpinSet :: c | b} => Lens' a c
_mpinSet = lens (unwrap >>> _.mpinSet) (\oldrec newval -> wrap ((unwrap oldrec) { mpinSet = newval }))

_maskedAccountNumber :: forall a b c. Newtype a { maskedAccountNumber :: c | b} => Lens' a c
_maskedAccountNumber = lens (unwrap >>> _.maskedAccountNumber) (\oldrec newval -> wrap ((unwrap oldrec) { maskedAccountNumber = newval }))

_updates :: forall a b c. Newtype a { updates :: c | b} => Lens' a c
_updates = lens (unwrap >>> _.updates) (\oldrec newval -> wrap ((unwrap oldrec) { updates = newval }))

_ifsc :: forall a b c. Newtype a { ifsc :: c | b} => Lens' a c
_ifsc = lens (unwrap >>> _.ifsc) (\oldrec newval -> wrap ((unwrap oldrec) { ifsc = newval }))

_iin :: forall a b c. Newtype a { iin :: c | b} => Lens' a c
_iin = lens (unwrap >>> _.iin) (\oldrec newval -> wrap ((unwrap oldrec) { iin = newval }))

_banks :: forall a b c. Newtype a { banks :: c | b} => Lens' a c
_banks = lens (unwrap >>> _.banks) (\oldrec newval -> wrap ((unwrap oldrec) { banks = newval }))

_upiNLAccounts :: forall a b c. Newtype a { upiNLAccounts :: c | b} => Lens' a c
_upiNLAccounts = lens (unwrap >>> _.upiNLAccounts) (\oldrec newval -> wrap ((unwrap oldrec) { upiNLAccounts = newval }))

_mobile :: forall a b c. Newtype a { mobile :: c | b} => Lens' a c
_mobile = lens (unwrap >>> _.mobile) (\oldrec newval -> wrap ((unwrap oldrec) { mobile = newval }))

_referenceId :: forall a b c. Newtype a { referenceId :: c | b} => Lens' a c
_referenceId = lens (unwrap >>> _.referenceId) (\oldrec newval -> wrap ((unwrap oldrec) { referenceId = newval }))

_upiState :: forall a b c. Newtype a { upiState :: c | b} => Lens' a c
_upiState = lens (unwrap >>> _.upiState) (\oldrec newval -> wrap ((unwrap oldrec) { upiState = newval }))

_shouldUpdate :: forall a b c. Newtype a { shouldUpdate :: c | b} => Lens' a c
_shouldUpdate = lens (unwrap >>> _.shouldUpdate) (\oldrec newval -> wrap ((unwrap oldrec) { shouldUpdate = newval }))

_fixedTab :: forall a b c. Newtype a { fixedTab :: c | b} => Lens' a c
_fixedTab = lens (unwrap >>> _.fixedTab) (\oldrec newval -> wrap ((unwrap oldrec) { fixedTab = newval }))

_upiLoaded :: forall a b c. Newtype a { upiLoaded :: c | b} => Lens' a c
_upiLoaded = lens (unwrap >>> _.upiLoaded) (\oldrec newval -> wrap ((unwrap oldrec) { upiLoaded = newval }))

_appsLoaded :: forall a b c. Newtype a { appsLoaded :: c | b} => Lens' a c
_appsLoaded = lens (unwrap >>> _.appsLoaded) (\oldrec newval -> wrap ((unwrap oldrec) { appsLoaded = newval }))

