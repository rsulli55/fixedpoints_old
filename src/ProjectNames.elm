module ProjectNames exposing (projectNames)

import DataSource exposing (DataSource)
import DataSource.Glob as Glob


projectNames : DataSource (List String)
projectNames =
    Glob.succeed (\capture -> capture)
        -- |> Glob.captureFilePath
        |> Glob.match (Glob.literal "content/projects/")
        |> Glob.capture Glob.wildcard
        |> Glob.match (Glob.literal ".md")
        |> Glob.toDataSource



-- |> DataSource.map (Debug.log "projectNames")
