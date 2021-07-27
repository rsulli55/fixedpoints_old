module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import Constants exposing (..)
import DataSource
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Path exposing (Path)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)


template : SharedTemplate Msg Model Data SharedMsg msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
    , sharedMsg = SharedMsg
    }


type Msg
    = OnPageChange
        { path : Path
        , query : Maybe String
        , fragment : Maybe String
        }
    | SharedMsg SharedMsg


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMobileMenu : Bool
    }


init :
    Maybe Browser.Navigation.Key
    -> Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : Path
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Cmd Msg )
init navigationKey flags maybePagePath =
    ( { showMobileMenu = False }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange _ ->
            ( { model | showMobileMenu = False }, Cmd.none )

        SharedMsg globalMsg ->
            ( model, Cmd.none )


subscriptions : Path -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : DataSource.DataSource Data
data =
    DataSource.succeed ()


view :
    Data
    ->
        { path : Path
        , frontmatter : route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : Html msg, title : String }
view sharedData page model toMsg pageView =
    { body =
        Element.layout
            [ Font.color colorPrimaryText
            , Font.size 16
            , Background.color colorBlack
            , Element.width Element.fill
            , Element.height Element.fill
            ]
        <|
            Element.column
                [ Element.width (Element.px 800)
                , Element.height Element.fill
                , Element.spacing 5
                , Element.centerX
                ]
                [ Element.row [ Element.width Element.fill ]
                    [ Element.el [ Element.alignLeft ] siteHeader
                    , Element.el [ Element.alignRight ] navBar
                    ]
                , mainContent pageView.body
                , siteFooter
                ]
    , title = pageView.title
    }


siteHeader : Element msg
siteHeader =
    Element.row
        [ Element.width Element.fill
        , Element.padding 10
        , Border.rounded 5
        , Font.size 24
        ]
        [ Element.link [] { url = "/", label = Element.text "Fixed Points" } ]


navBarItem : { url : String, label : String } -> Element msg
navBarItem item =
    Element.el
        [ Border.rounded 3
        , Background.color colorPrimary
        , Element.padding 8
        , Element.pointer
        , Element.mouseOver [ Background.color colorPrimaryHighlight ]
        ]
        (Element.link [] { url = item.url, label = Element.text item.label })


navBar =
    navBarBuilder [ { url = "/projects", label = "Projects" }, { url = "/posts", label = "Posts" }, { url = "/about", label = "About" } ]


navBarBuilder : List { url : String, label : String } -> Element msg
navBarBuilder items =
    Element.row [ Element.spacing 5, Element.padding 5, Element.width Element.fill, Border.rounded 5 ] <|
        List.map
            navBarItem
            items



-- mainContent : View msg -> Element msg


mainContent : List (Element msg) -> Element msg
mainContent content =
    Element.column
        [ Element.spacing 10
        , Element.padding 10
        , Element.width Element.fill
        , Element.height Element.fill
        , Background.color colorDarkGrey
        , Border.rounded 5
        ]
        content


siteFooter : Element msg
siteFooter =
    siteFooterBuilder
        ([ Element.newTabLink [] { url = "https://www.linkedin.com/in/ryan-sullivant/", label = Element.text "LinkedIn" }
         , Element.newTabLink [] { url = "https://github.com/rsulli55", label = Element.text "Github" }
         ]
            |> List.intersperse
                (Element.el [ Font.size 10, Element.centerX ]
                    (Element.text
                        "⚪"
                    )
                )
        )


siteFooterBuilder : List (Element msg) -> Element msg
siteFooterBuilder elements =
    Element.column
        [ Element.centerX
        , Element.spacing 5
        ]
        [ Element.row
            [ Border.rounded 5
            , Element.padding 5
            , Element.spacing 10
            , Element.centerX
            ]
            elements
        , Element.el
            [ Element.width Element.fill
            , Font.size 12
            , Element.padding 5
            , Element.centerX
            ]
            (Element.text "Copyright Ryan Sullivant")
        ]
