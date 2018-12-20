module UI.View.Component.WalletsView where

import Prelude

import Data.Array
import Data.Lens
import Data.Maybe
import Data.Newtype
import Foreign.Object as Object
import Data.String.CodePoints as S
import Effect
import Engineering.Helpers.Types.Accessor
import Data.Int
import Data.Lens
import Engineering.Helpers.Commons
import Engineering.Helpers.Events

import PrestoDOM
import PrestoDOM.Core (mapDom)
import PrestoDOM.Utils ((<>>))

import Product.Types (CurrentOverlay(DebitCardOverlay), SIM(..), UPIState(..))
import Product.Types as Types
import UI.Constant.Color.Default as Color
import UI.Constant.FontColor.Default as FontColor
import UI.Constant.FontSize.Default as FontSize
import UI.Constant.FontStyle.Default as Font
import UI.Constant.FontStyle.Default as FontStyle
import UI.Constant.Str.Default as STR
import UI.Constant.Type (FontColor, FontStyle)

import UI.Helpers.CommonView
import UI.Controller.Component.WalletsView
import UI.View.Component.CardLayout as CardLayout
import UI.Helpers.SingleSelectRadio as Radio
import UI.Utils
import UI.Config as Config
import Validation

view
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> Object.Object GenProp
	-> PrestoDOM (Effect Unit) w
view push state _ =
    relativeLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        [ walletListView push state
        , linkWalletSection push state
        ]

walletListView
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> PrestoDOM (Effect Unit) w
walletListView push state =
    let radioState = state ^. _walletSelected
        walletList = state ^. _walletList
        currentSelected = radioState ^. _currentSelected
        proceedImpl = overrides push state ProceedToPay
        actionImpl = overrides push state <<< LinkButton
        sectionSelected = state ^. _sectionSelected
     in linearLayout
        [ height $ V 600
        , width MATCH_PARENT
        , orientation VERTICAL
        , visibility $ case sectionSelected of
                            WalletListSection -> VISIBLE
                            _ -> GONE
        ]
        $ Radio.singleSelectRadio
            (push <<< WalletSelected)
            radioState
            (CardLayout.view proceedImpl actionImpl)
            ( walletInfo <$> walletList )

    where
          walletInfo = \w -> { piName : getWalletName (w ^. _wallet)
                         , offer : ""
                         , imageUrl : getWalletIcon (w ^. _wallet)
                         , balance : w ^. _currentBalance
                         , actionButton : case w ^. _currentBalance of
                                               Just _ -> CardLayout.DeleteAccount
                                               Nothing -> CardLayout.LinkAccount
                         }



linkWalletSection
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> PrestoDOM (Effect Unit) w
linkWalletSection push state =
    let sectionSelected = state ^. _sectionSelected
        expandBtnImpl = overrides push state $ SectionSelectionOverride  WalletListSection
     in linearLayout
        [ height $ V 431
        , width MATCH_PARENT
        , orientation VERTICAL
        , visibility $ case sectionSelected of
                            LinkWalletSection _ -> VISIBLE
                            _ -> GONE
        ]
        [ expandButton { text : "Other Wallets", visibility : VISIBLE, implementation : expandBtnImpl}
        , linkWalletView push state
        ]

linkWalletView
	:: forall w
	. (Action -> Effect Unit)
	-> State
	-> PrestoDOM (Effect Unit) w
linkWalletView push state =
    let radioState = state ^. _walletSelected
        walletList = state ^. _walletList
        currentSelected = radioState ^. _currentSelected
        selectedGateway = unsafeGetGateway walletList currentSelected
        piName = getWalletName selectedGateway
        mobile = state ^. _customerMobile
        implementation = \st -> overrides push state $ CreateWalletOverride st currentSelected
        balance = state ^. _linkWalletDetails ^. _current_balance
        otpImpl = overrides push state OTPField
     in linearLayout
        [ height $ V 321
        , width MATCH_PARENT
        , orientation VERTICAL
        , padding $ PaddingLeft 35
        , background "#FFFFFF"
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ]
        [  linearLayout
            [ height $ V 66
            , width MATCH_PARENT
            ]
            [ CardLayout.piInfoView
                { imageUrl : getWalletIcon selectedGateway
                , piName : piName
                }
            ]
        , textView
            [ height $ V 16
            , width MATCH_PARENT
            , margin $ MarginTop 60
            , text $ case  sectionSelected of
                        LinkWalletSection Linking ->
                            "Proceed to link " <> piName <> " wallet with your number:"
                        LinkWalletSection OTPView ->
                            "Enter the One time password sent to your mobile number"
                        LinkWalletSection PayView ->
                            "Wallet Balance"
                        _ -> ""
            , textSize 14
            , color "#545758"
            ]
        , linearLayout
            [ height $ V 60
            , width $ V 400
            , margin $ MarginTop 15
            , orientation VERTICAL
            ]
            ( case  sectionSelected of
                    LinkWalletSection Linking ->
                        [ textView
                            [ height $ V 27
                            , width MATCH_PARENT
                            , letterSpacing 1.2
                            , text mobile
                            , textSize 24
                            ]
                        ]
                    LinkWalletSection OTPView ->
                        [ editField
                            otpImpl
                            { hint : "OTP"
                            , width : MATCH_PARENT
                            , weight : 0.0
                            , margin : MarginLeft 0
                            , inputType : Numeric
                            }
                        ]
                    LinkWalletSection PayView ->
                        [ textView
                            [ height $ V 33
                            , width MATCH_PARENT
                            , letterSpacing 1.2
                            , color "#545758"
                            , text $ show balance
                            , textSize 24
                            ]
                        , textView
                            [ height $ V 18
                            , width MATCH_PARENT
                            , color "#FF7676"
                            , text "Insufficent Balance"
                            , textSize 16
                            ]
                        ]
                    _ -> []
            )
        , relativeLayout
            [ height $ V 60
            , width $ V 300
            ]
            [ linearLayout
                [ height $ V 60
                , width $ V 300
                , visibility $ getVisibility Linking
                , orientation HORIZONTAL
                ]
                [ buttonView
                    (implementation Linking)
                    { width : V 300
                    , text : "Proceed"
                    , margin : MarginTop 20
                    }
                ]
            , linearLayout
                [ height $ V 60
                , width $ V 300
                , visibility $ getVisibility OTPView
                , orientation HORIZONTAL
                ]
                [ buttonView
                    (implementation OTPView)
                    { width : V 300
                    , text : "Confirm"
                    , margin : MarginTop 20
                    }
                ]
            , linearLayout
                [ height $ V 60
                , width $ V 300
                , visibility $ getVisibility PayView
                , orientation HORIZONTAL
                ]
                [ buttonView
                    (implementation Linking)
                    { width : V 300
                    , text : "pay Securely"
                    , margin : MarginTop 20
                    }
                ]
            ]

        ]

        where
              sectionSelected = state ^. _sectionSelected

              getVisibility curr =
                  case sectionSelected of
                       LinkWalletSection s -> if s == curr then VISIBLE else GONE
                       _ -> GONE



expandButton config =
    linearLayout
        ([ height $ V 100
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        , padding $ PaddingHorizontal 35 33
        , margin $ MarginBottom 10
        , visibility config.visibility
        , background "#FFFFFF"
        , shadow $ Shadow 0.0 2.0 4.0 1.0 "#12000000" 1.0
        ] <>> config.implementation)
        [ textView
            [ height $ V 28
            , textSize 24
            , text config.text
            , fontStyle "Arial-Regular"
            ]
        ]







