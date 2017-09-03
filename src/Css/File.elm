module Css.File exposing (CssCompilerProgram, CssFileStructure, UniqueClass, compile, compiler, toFileStructure, uniqueClass)

{-| Functions for writing CSS files from elm-css.

@docs compile, compiler, toFileStructure, CssFileStructure, CssCompilerProgram


## Automatically-generated unique classes

@docs UniqueClass, uniqueClass

-}

import Css exposing (Snippet, Style, Stylesheet)


{-| A description of CSS files that will be created by elm-css.
-}
type alias CssFileStructure =
    List
        { filename : String
        , content : String
        , success : Bool
        }


{-| Translate a list of filenames and [`prettyPrint`](#prettyPrint) results
to a list of tuples suitable for being sent to a port in a Stylesheets.elm file.
-}
toFileStructure : List ( String, { css : String, warnings : List String } ) -> CssFileStructure
toFileStructure stylesheets =
    let
        asTuple ( filename, { css, warnings } ) =
            { success = List.isEmpty warnings, filename = filename, content = css }
    in
    List.map asTuple stylesheets


{-| Convenience re-export of Css.compile
-}
compile : List Stylesheet -> { css : String, warnings : List String }
compile =
    Css.compile


{-| Create a program that compiles an elm-css stylesheet to a CSS file.

    import Css.File exposing (CssCompilerProgram, CssFileStructure)
    import HomepageCss as Homepage

    port files : CssFileStructure -> Cmd msg

    fileStructure : CssFileStructure
    fileStructure =
        Css.File.toFileStructure
            [ ( "homepage.css", Css.File.compile [ Homepage.css ] ) ]

    main : CssCompilerProgram
    main =
        Css.File.compiler files fileStructure

-}
compiler : (CssFileStructure -> Cmd Never) -> CssFileStructure -> CssCompilerProgram
compiler filesPort structure =
    Platform.program
        { init = ( (), filesPort structure )
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


{-| A prorgam that compiles a CSS file.

See [`compiler`](#compiler).

-}
type alias CssCompilerProgram =
    Program Never () Never


{-| Styles scoped under an automatically-generated class.
-}
type UniqueClass
    = UniqueClass (List Style)


{-| Create a style scoped under an automatically-generated class that is
guaranteed to be unique - at least relative to other class names generated
using this function!
-}
uniqueClass : List Style -> UniqueClass
uniqueClass =
    UniqueClass
