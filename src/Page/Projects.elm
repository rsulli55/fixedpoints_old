module Page.Projects exposing (Data, Model, Msg, page)

import Browser.Navigation
import Constants exposing (..)
import Css
import DataSource exposing (DataSource)
import DataSource.File
import DataSource.Glob as Glob
import DataSource.Http
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import GithubRepo exposing (GithubRepo)
import Head
import Head.Seo as Seo
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr exposing (css)
import MdRendering
import OptimizedDecoder as Decode
import Page exposing (Page, PageWithState, StaticPayload)
import Pages.PageUrl exposing (PageUrl)
import Pages.Url
import Palette exposing (debugBorder)
import Path exposing (Path)
import ProjectNames exposing (projectNames)
import Secrets
import Shared
import Tailwind.Utilities as Tw
import Url.Builder as UrlBuilder
import View exposing (View)



-- type alias Project =
--     { repo : Repo
--     , details : String
--     , expanded : Bool
--     }


type alias RepoDetails =
    String



-- projectNames : DataSource (List String)
-- projectNames =
--     Glob.succeed (\capture -> capture)
--         -- |> Glob.captureFilePath
--         |> Glob.match (Glob.literal "content/projects/")
--         |> Glob.capture Glob.wildcard
--         |> Glob.match (Glob.literal ".md")
--         |> Glob.toDataSource
--         |> DataSource.map (Debug.log "ProjectNames")


projectRepos : DataSource (List GithubRepo)
projectRepos =
    DataSource.map GithubRepo.getRepos projectNames
        |> DataSource.resolve
        |> DataSource.map (Debug.log "projectRepos")


getFilePath : String -> String
getFilePath name =
    "content/projects/" ++ name ++ ".md"



-- getDetail : String -> DataSource String
-- getDetail name =
--     DataSource.File.bodyWithoutFrontmatter (getFilePath name)
-- projectDetails : DataSource (List String)
-- projectDetails =
--     DataSource.map (List.map getDetail) projectNames
--         |> DataSource.resolve
--         |> DataSource.map (Debug.log "projectDetails")
-- combineRepoAndDetails : List Repo -> List String -> List Project
-- combineRepoAndDetails =
--     List.map2 (\repo details -> { repo = repo, details = details, expanded = False })
-- projects : DataSource (List Project)
-- projects =
--     DataSource.map2 combineRepoAndDetails projectRepos projectDetails
-- projectDetailsButton : Project -> Model -> Element Msg
-- projectDetailsButton project model =
--     let
--         expanded =
--             case Dict.get project.repo.name model.expanded of
--                 Just bool ->
--                     bool
--                 Nothing ->
--                     False
--     in
--     let
--         buttonText =
--             if expanded then
--                 "Collapse Details ⤴"
--             else
--                 "Expand Details ⤵"
--     in
--     let
--         button =
--             Input.button
--                 [ Background.color colorPrimary
--                 , Element.mouseOver [ Background.color colorPrimaryHighlight ]
--                 , Border.rounded 5
--                 , Element.alignRight
--                 ]
--                 { onPress = Just (Toggle project.repo.name)
--                 , label =
--                     Element.text buttonText
--                 }
--     in
--     let
--         renderedMd =
--             if expanded then
--                 Element.paragraph [ Background.color colorMedGrey, Element.width Element.fill ]
--                     [ MdRendering.renderMd project.details ]
--             else
--                 Element.none
--     in
--     Element.column
--         [ Element.spacing 10
--         , Element.width Element.fill
--         ]
--         [ button, renderedMd ]


displayRepo : GithubRepo -> Html Msg
displayRepo repo =
    let
        repoName =
            GithubRepo.getName repo
    in
    let
        description =
            case GithubRepo.getDesc repo of
                Just desc ->
                    "Description: " ++ desc

                Nothing ->
                    "No Description"
    in
    let
        repoTitle =
            case GithubRepo.getLanguage repo of
                Just lang ->
                    lang ++ ": " ++ repoName

                Nothing ->
                    repoName
    in
    let
        lastUpdated =
            "Last updated: " ++ GithubRepo.getDate repo
    in
    let
        url =
            GithubRepo.getUrl repo
    in
    Html.div [ css [ Tw.grid, Tw.space_y_2, Tw.p_2, Tw.bg_gray_900, Tw.rounded ] ]
        [ Html.span [ css [ Tw.inline_flex ] ]
            [ Html.span [ css [ Tw.text_2xl, Tw.flex_grow ] ] [ Html.text repoTitle ]
            , Html.span
                [ css
                    [ Tw.text_gray_100
                    , Tw.bg_gray_800
                    , Tw.rounded
                    , Css.hover [ Tw.bg_gray_700 ]
                    ]
                ]
                [ Html.a
                    [ Attr.href ("/projects/" ++ repoName)
                    , css
                        [ Tw.text_gray_100
                        , Tw.text_lg
                        , Tw.m_1_dot_5
                        ]
                    ]
                    [ Html.text "More Details" ]
                ]
            ]
        , Html.span [ css [ Tw.text_gray_100 ] ] [ Html.text description ]
        , Html.span [ css [ Tw.text_gray_100 ] ] [ Html.text lastUpdated ]
        , Html.span []
            [ Html.a
                [ Attr.href url
                , css [ Tw.underline, Tw.text_gray_400, Css.hover [ Tw.text_gray_200 ] ]
                ]
                [ Html.text url ]
            ]
        ]


displayRepos : List GithubRepo -> Html Msg
displayRepos repos =
    Html.div
        [ css
            [ Tw.grid
            , Tw.auto_cols_auto
            , Tw.flex_grow
            , Tw.space_y_2
            , Tw.px_4
            , Tw.py_2
            ]
        ]
    <|
        List.map
            displayRepo
            repos



-- Element.column
--     [ Element.width Element.fill
--     , Element.spacing 15
--     , Element.paddingXY 25 5
--     ]
--     (List.map
--         (displayProject model)
--         projs
--     )


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


type alias Data =
    List GithubRepo


data : DataSource Data
data =
    projectRepos


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


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Fixed Points - Personal Projects"
    , body =
        [ Html.span [ css [ Tw.flex, Tw.justify_center, Tw.text_3xl ] ] [ Html.text "Personal Projects" ]
        , displayRepos static.data
        ]
    }



--     Element.column
--         [ Element.spacing 10
--         , Element.padding 10
--         , Background.color colorMedGrey
--         , Element.width Element.fill
--         , Border.rounded 5
--         ]
--         [ Element.el [ Font.size 24 ] (Element.text repoTitle)
--         , Element.el [ Font.color colorSecondaryText ]
--             (Element.text description)
--         , Element.newTabLink
--             [ Font.color colorDisabledText
--             , Element.mouseOver [ Font.color colorPrimaryText ]
--             ]
--             { url = project.repo.htmlUrl, label = Element.text project.repo.htmlUrl }
--         , projectDetailsButton project model
--         ]
-- displayProjects : Model -> List Project -> Element Msg
-- displayProjects model projs =
--     Element.column
--         [ Element.width Element.fill
--         , Element.spacing 15
--         , Element.paddingXY 25 5
--         ]
--         (List.map
--             (displayProject model)
--             projs
--         )
-- type alias RepoName =
--     String
-- type alias Model =
--     { expanded : Dict RepoName Bool }
-- type Msg
--     = Toggle RepoName
-- type alias RouteParams =
--     {}
-- page : PageWithState RouteParams Data Model Msg
-- page =
--     Page.single
--         { head = head
--         , data = data
--         }
--         |> Page.buildWithLocalState { view = view, init = init, update = update, subscriptions = subscriptions }
-- init : Maybe PageUrl -> Shared.Model -> StaticPayload Data RouteParams -> ( Model, Cmd Msg )
-- init maybePageUrl model static =
--     let
--         allFalse =
--             List.map (\project -> ( project.repo.name, False )) static.data
--     in
--     ( { expanded = Dict.fromList allFalse }, Cmd.none )
-- update : PageUrl -> Maybe Browser.Navigation.Key -> Shared.Model -> StaticPayload Data RouteParams -> Msg -> Model -> ( Model, Cmd Msg )
-- update pageUrl maybeKey sharedModel static msg model =
--     let
--         toggleBool maybeBool =
--             case maybeBool of
--                 Just bool ->
--                     Just (not bool)
--                 Nothing ->
--                     Just False
--     in
--     case msg of
--         Toggle name ->
--             ( { model | expanded = Dict.update name toggleBool model.expanded }, Cmd.none )
-- subscriptions : Maybe PageUrl -> RouteParams -> Path -> Model -> Sub Msg
-- subscriptions maybePageUrl routeParams path model =
--     Sub.none
-- type alias Data =
--     List Project
-- data : DataSource Data
-- data =
--     projects
-- head :
--     StaticPayload Data RouteParams
--     -> List Head.Tag
-- head static =
--     Seo.summary
--         { canonicalUrlOverride = Nothing
--         , siteName = "Fixed Points"
--         , image =
--             { url = Pages.Url.external "TODO"
--             , alt = "Fixed Points logo"
--             , dimensions = Nothing
--             , mimeType = Nothing
--             }
--         , description = "Fixed Points - Projects"
--         , locale = Nothing
--         , title = "Fixed Points - Projects" -- metadata.title -- TODO
--         }
--         |> Seo.website
-- view :
--     Maybe PageUrl
--     -> Shared.Model
--     -> Model
--     -> StaticPayload Data RouteParams
--     -> View Msg
-- view maybeUrl sharedModel model static =
--     { title = "Fixed Points - Personal Projects"
--     , body = [ Element.el [ Font.size 30, Element.centerX ] (Element.text "Personal Projects"), displayProjects model static.data ]
--     }
