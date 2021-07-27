module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import Element
import Element.Background as Background
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Page exposing (Page, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Shared
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    {}


page : Page RouteParams Data
page =
    Page.single
        { head = head
        , data = data
        }
        |> Page.buildNoState { view = view }


data : DataSource Data
data =
    DataSource.succeed "/content/images/fixed_point_def.png"
        |> DataSource.map (Debug.log "image path")


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "TODO"
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


type alias Data =
    String


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Fixed Points"
    , body =
        [ Html.p []
            [ Html.text "Hi there, my name is Ryan, welcome to my site.  I am currently a M.S. student at the Univerity of Arizona.  Before that I completed a Ph.D. in Mathematics at UC Irvine.  For my Ph.D. I studied"
            , Html.em [] [ Html.text " inner model theory" ]
            , Html.text " which is an area of set theory. "
            ]
        ]
    }
