module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Browser.Navigation
import Css
import Css.Global
import DataSource
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr exposing (css)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Palette exposing (debugBorder)
import Path exposing (Path)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Tailwind.Breakpoints as Bp
import Tailwind.Utilities as Tw
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just OnPageChange
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



-- view :
--     Data
--     ->
--         { path : Path
--         , route : Maybe Route
--         }
--     -> Model
--     -> (Msg -> msg)
--     -> View msg
--     -> { body : Html msg, title : String }


view sharedData page model toMsg pageView =
    { body =
        Html.div []
            [ Css.Global.global Tw.globalStyles

            -- , Html.node "link" [ Attr.href "https://fonts.googleapis.com/css?family=Source+Code+Pro", Attr.rel "stylesheet", Attr.name "Source Code Pro" ] []
            , Html.node "link" [ Attr.href "https://cdnjs.cloudflare.com/ajax/libs/hack-font/3.3.0/web/hack-subset.css", Attr.rel "stylesheet", Attr.name "Hack" ] []
            , Html.div
                [ css
                    -- <|
                    --     debugBorder
                    [ Css.backgroundColor (Css.rgb 20 20 20)
                    , Tw.text_base

                    -- , Tw.max_w_full
                    , Tw.min_h_screen
                    , Tw.text_gray_300
                    , Tw.flex

                    -- , Tw.flex_grow
                    , Tw.justify_center
                    ]
                ]
                [ Html.div
                    [ css
                        -- <|
                        --     debugBorder
                        [ Tw.grid
                        , Tw.auto_rows_min
                        , Tw.max_w_4xl
                        , Tw.justify_self_center
                        , Tw.space_y_4
                        , Tw.flex_grow
                        , Tw.pt_4
                        ]
                    ]
                    [ Html.div
                        [ css
                            -- <|
                            --     debugBorder
                            [ Tw.grid
                            , Tw.grid_cols_2

                            -- , Tw.grid_rows_2
                            -- , Tw.grid_flow_row_dense
                            ]
                        ]
                        [ siteHeader
                        , navBar
                        ]
                    , mainContent pageView.body
                    , siteFooter
                    ]
                ]
            ]
            |> Html.toUnstyled
    , title = pageView.title
    }


siteHeader : Html msg
siteHeader =
    Html.div
        [ css
            -- <|
            --     debugBorder
            [ -- TODO: Fix this HACK. It pushes the logo down a bit.
              Tw.pt_0_dot_5
            ]
        ]
        [ Html.a [ Attr.href "/", css [] ]
            [ Html.img
                [ Attr.src "images/logo_white_with_text.svg"
                , Attr.alt "Fixed Points logo"
                ]
                []
            ]
        ]


navBarItem : { url : String, label : String } -> Html msg
navBarItem item =
    Html.a
        [ Attr.href item.url
        , css
            -- <|
            --     debugBorder
            [ Tw.rounded
            , Tw.bg_gray_800
            , Tw.cursor_pointer
            , Tw.p_1_dot_5
            , Css.hover [ Tw.bg_gray_700 ]
            ]
        ]
        [ Html.text item.label
        ]


navBar =
    navBarBuilder
        [ { url = "/projects", label = "Projects" }
        , { url = "/posts", label = "Posts" }
        , { url = "/about", label = "About" }
        ]


navBarBuilder : List { url : String, label : String } -> Html msg
navBarBuilder items =
    Html.div
        [ css
            -- <|
            --     debugBorder
            [ Tw.grid
            , Tw.grid_rows_1
            , Tw.grid_flow_col_dense
            , Tw.space_x_2
            , Tw.justify_end
            ]
        ]
    <|
        List.map navBarItem items


mainContent : List (Html msg) -> Html msg
mainContent content =
    Html.div
        [ css
            [ Tw.p_6
            , Tw.bg_gray_800
            , Tw.rounded_lg
            , Tw.flex_grow
            , Tw.min_h_full
            ]
        ]
        content


siteFooter : Html msg
siteFooter =
    siteFooterBuilder
        ([ Html.a [ Attr.href "https://www.linkedin.com/in/ryan-sullivant/", Attr.target "_blank" ]
            [ Html.text "LinkedIn" ]
         , Html.a [ Attr.href "https://github.com/rsulli55", Attr.target "_blank" ]
            [ Html.text "Github" ]
         ]
            -- TODO: Fix this hack of pushing the span down
            |> List.intersperse (Html.span [ css [ Tw.text_xs, Tw.pt_1 ] ] [ Html.text "⚪" ])
        )


siteFooterBuilder : List (Html msg) -> Html msg
siteFooterBuilder elements =
    Html.div [ css [ Tw.grid, Tw.w_full, Tw.auto_rows_min, Tw.justify_center, Tw.py_8 ] ]
        [ Html.span [ css [ Tw.inline_flex, Tw.justify_center, Tw.space_x_2 ] ]
            elements
        , Html.span [ css [ Tw.text_sm ] ] [ Html.text "Copyright Ryan Sullivant" ]
        ]
