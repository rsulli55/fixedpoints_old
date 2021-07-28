module Page.Projects.Name_ exposing (Data, Model, Msg, page)

import Css
import DataSource exposing (DataSource)
import DataSource.File
import Head
import Head.Seo as Seo
import Html.Styled as Html
import Html.Styled.Attributes as Attr exposing (css)
import MdRendering
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import ProjectNames exposing (projectNames)
import Shared
import Tailwind.Utilities as Tw
import TailwindMarkdownRenderer
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { name : String }



-- projectMarkdowns : DataSource (List String)
-- projectMarkdowns =
--     DataSource.map (List.map getProjectMd) projectNames
--         |> DataSource.resolve
--         |> DataSource.map (Debug.log "projectMarkdowns")


page : Page RouteParams Data
page =
    Page.prerender
        { head = head
        , routes = routes
        , data = data
        }
        |> Page.buildNoState { view = view }


routes : DataSource (List RouteParams)
routes =
    DataSource.map (List.map (\name -> RouteParams name)) projectNames


getProjectMarkdown : String -> DataSource String
getProjectMarkdown name =
    DataSource.File.bodyWithoutFrontmatter ("content/projects/" ++ name ++ ".md")


data : RouteParams -> DataSource Data
data routeParams =
    DataSource.map2 Data
        (DataSource.succeed routeParams.name)
        (getProjectMarkdown routeParams.name)


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "Fixed Points"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "Fixed Points - " ++ static.data.route
        , locale = Nothing
        , title = "TODO title" -- metadata.title -- TODO
        }
        |> Seo.website


type alias Data =
    { route : String, markdown : String }


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Fixed Points - " ++ static.data.route
    , body =
        [ Html.div
            [ css
                [ Tw.flex
                , Tw.flex_grow
                , Tw.bg_gray_900
                , Tw.py_2
                , Tw.m_4
                , Tw.px_4
                , Tw.rounded
                ]
            ]
            [ MdRendering.renderMd static.data.markdown ]
        ]
    }
