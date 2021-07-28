module Page.Index exposing (Data, Model, Msg, page)

import DataSource exposing (DataSource)
import DataSource.File
import Element
import Element.Background as Background
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import MdRendering
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



-- logoFileName : DataSource String
-- logoFileName =
--     DataSource.succeed "/content/images/fixed_point_def.png"
--         |> DataSource.map (Debug.log "image path")


markdown : DataSource String
markdown =
    DataSource.File.bodyWithoutFrontmatter "/content/index.md"


data : DataSource Data
data =
    markdown


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "fixedpoints"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Fixed Points - Index"
        , locale = Nothing
        , title = "Fixed Points - Index" -- metadata.title -- TODO
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
        [ Html.div []
            [ MdRendering.renderMd static.data ]
        ]
    }
