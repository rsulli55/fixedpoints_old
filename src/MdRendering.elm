module MdRendering exposing (MdMsg, renderMd)

import Constants exposing (..)
import Element exposing (Element, rgb255)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input
import Element.Region
import Html
import Html.Attributes
import Html.Styled
import Markdown.Block as Block exposing (Block, Inline, ListItem(..), Task(..))
import Markdown.Html
import Markdown.Option exposing (..)
import Markdown.Parser
import Markdown.Render exposing (MarkdownMsg(..), MarkdownOutput(..))
import Markdown.Renderer
import SyntaxHighlight
import TailwindMarkdownRenderer


type MdMsg
    = MarkdownMsg Markdown.Render.MarkdownMsg


deadEndsToString deadEnds =
    List.map Markdown.Parser.deadEndToString deadEnds
        |> String.join "\n"


renderMdWithRenderer renderer markdown =
    case
        markdown
            |> Markdown.Parser.parse
            |> Result.mapError deadEndsToString
            |> Result.andThen (\ast -> Markdown.Renderer.render renderer ast)
    of
        Ok rendered ->
            Html.Styled.div [] rendered |> Html.Styled.toUnstyled |> Element.html

        -- Element.paragraph [] rendered
        Err errors ->
            Element.el [ Font.size 24, Font.color (Element.rgb255 230 20 20) ] (Element.text errors)


type alias Renderer view =
    { heading : { level : Block.HeadingLevel, rawText : String, children : List view } -> view
    , paragraph : List view -> view
    , blockQuote : List view -> view
    , html : Markdown.Html.Renderer (List view -> view)
    , text : String -> view
    , codeSpan : String -> view
    , strong : List view -> view
    , emphasis : List view -> view
    , strikethrough : List view -> view
    , hardLineBreak : view
    , link : { title : Maybe String, destination : String } -> List view -> view
    , image : { alt : String, src : String, title : Maybe String } -> view
    , unorderedList : List (ListItem view) -> view
    , orderedList : Int -> List (List view) -> view
    , codeBlock : { body : String, language : Maybe String } -> view
    , thematicBreak : view
    , table : List view -> view
    , tableHeader : List view -> view
    , tableBody : List view -> view
    , tableRow : List view -> view
    , tableCell : Maybe Block.Alignment -> List view -> view
    , tableHeaderCell : Maybe Block.Alignment -> List view -> view
    }


elmUiRenderer : Markdown.Renderer.Renderer (Element msg)
elmUiRenderer =
    { heading = heading
    , paragraph =
        Element.paragraph
            [ Element.spacing 15, Element.padding 5 ]
    , thematicBreak = Element.column [ Element.width Element.fill, Element.spacing 5, Font.color (Element.rgb255 255 0 0) ] [ Element.text "thematicBreak" ]
    , text = \content -> Element.el [ Element.width Element.fill ] (Element.text content)
    , strong = \content -> Element.row [ Font.bold, Element.explain Debug.todo ] content
    , emphasis = \content -> Element.row [ Font.italic, Element.explain Debug.todo ] content
    , strikethrough = \content -> Element.row [ Font.strike ] content
    , codeSpan = code
    , link =
        \{ title, destination } body ->
            Element.newTabLink
                [ Element.htmlAttribute (Html.Attributes.style "display" "inline-flex") ]
                { url = destination
                , label =
                    Element.paragraph
                        [ Font.color colorDisabledText
                        , Element.explain Debug.todo
                        ]
                        body
                }
    , hardLineBreak = Element.column [ Element.width Element.fill, Element.spacing 5, Font.color (Element.rgb255 255 0 0) ] [ Element.text "hardBreak" ]
    , image =
        \image ->
            case image.title of
                Just title ->
                    Element.image [ Element.width Element.fill ] { src = image.src, description = image.alt }

                Nothing ->
                    Element.image [ Element.width Element.fill ] { src = image.src, description = image.alt }
    , blockQuote =
        \children ->
            Element.column
                [ Border.widthEach { top = 0, right = 0, bottom = 0, left = 10 }
                , Element.padding 10
                , Border.color (Element.rgb255 145 145 145)
                , Background.color (Element.rgb255 245 245 245)
                ]
                children
    , unorderedList =
        \items ->
            Element.column
                [ Element.spacing 15
                , Element.width Element.fill
                , Element.padding 5
                , Element.explain Debug.todo
                ]
                (items
                    |> List.map
                        (\(ListItem task children) ->
                            Element.row [ Element.spacing 5, Element.width Element.fill ]
                                [ Element.row
                                    [ Element.alignTop ]
                                    ((case task of
                                        IncompleteTask ->
                                            Element.Input.defaultCheckbox False

                                        CompletedTask ->
                                            Element.Input.defaultCheckbox True

                                        NoTask ->
                                            Element.text "•"
                                     )
                                        :: Element.text " "
                                        :: children
                                    )
                                ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            Element.column [ Element.spacing 15, Element.explain Debug.todo ]
                (items
                    |> List.indexedMap
                        (\index itemBlocks ->
                            Element.row [ Element.spacing 5, Element.explain Debug.todo, Element.width Element.fill ]
                                -- [ Element.row [ Element.alignTop, Element.explain Debug.todo ]
                                (Element.text (String.fromInt (index + startingIndex) ++ " ") :: itemBlocks)
                         -- ]
                        )
                )
    , codeBlock = codeBlock
    , html = Markdown.Html.oneOf []
    , table = Element.column []
    , tableHeader = Element.column []
    , tableBody = Element.column []
    , tableRow = Element.row []
    , tableHeaderCell =
        \maybeAlignment children ->
            Element.paragraph [] children
    , tableCell =
        \maybeAlignment children ->
            Element.paragraph [] children
    }


renderMd =
    renderMdWithRenderer TailwindMarkdownRenderer.renderer



-- renderMd markdown =
--     Element.paragraph []
--         [ Markdown.Render.toHtml ExtendedMath markdown
--             |> Html.map MarkdownMsg
--             |> Element.html
--         ]
-- TODO: Put  SyntaxHighlight.useTheme SyntaxHighlight.oneDark somewhere


code : String -> Element msg
code snippet =
    SyntaxHighlight.noLang snippet
        |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
        |> Result.map Element.html
        |> Result.withDefault
            (Element.text "Default!")



-- [ Background.color
--     (Element.rgba 0 0 0 0.04)
-- , Border.rounded 2
-- , Element.paddingXY 5 3
-- , Element.explain Debug.todo
-- , Font.family
--     [ Font.external
--         { url = "https://fonts.googleapis.com/css?family=Source+Code+Pro"
--         , name = "Source Code Pro"
--         }
--     ]
-- ]
-- (Element.text
--     snippet
-- )


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock details =
    let
        highlighter =
            case details.language of
                Just "elm" ->
                    SyntaxHighlight.elm

                Just "python" ->
                    SyntaxHighlight.python

                Just "javascript" ->
                    SyntaxHighlight.javascript

                Just "json" ->
                    SyntaxHighlight.json

                Just "sql" ->
                    SyntaxHighlight.sql

                Just "css" ->
                    SyntaxHighlight.css

                Just "xml" ->
                    SyntaxHighlight.xml

                _ ->
                    SyntaxHighlight.noLang
    in
    highlighter details.body
        |> Result.map (SyntaxHighlight.toBlockHtml (Just 1))
        |> Result.map Element.html
        |> Result.withDefault
            (Element.el
                [ Background.color (Element.rgba 0 0 0 0.03)
                , Element.htmlAttribute (Html.Attributes.style "white-space" "pre")
                , Element.padding 20
                , Font.family
                    [ Font.external
                        { url = "https://fonts.googleapis.com/css?family=Source+Code+Pro"
                        , name = "Source Code Pro"
                        }
                    ]
                ]
                (Element.text details.body)
            )


heading : { level : Block.HeadingLevel, rawText : String, children : List (Element msg) } -> Element msg
heading { level, rawText, children } =
    Element.paragraph
        [ Font.size
            (case level of
                Block.H1 ->
                    36

                Block.H2 ->
                    24

                _ ->
                    20
            )
        , Font.bold
        , Font.family [ Font.typeface "Montserrat" ]
        , Element.Region.heading (Block.headingLevelToInt level)
        , Element.htmlAttribute
            (Html.Attributes.attribute "name" (rawTextToId rawText))
        , Element.htmlAttribute
            (Html.Attributes.id (rawTextToId rawText))
        ]
        children


rawTextToId rawText =
    rawText
        |> String.split " "
        |> Debug.log "split"
        |> String.join "-"
        |> Debug.log "joined"
        |> String.toLower
