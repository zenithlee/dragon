﻿// --------------------------------------------------------------------------------------
// Builds the documentation from `.fsx` and `.md` files in the 'docs/content' directory
// (the generated documentation is stored in the 'docs/output' directory)
// --------------------------------------------------------------------------------------

// Binaries that have XML documentation (in a corresponding generated XML file)
let referenceBinaries = [ "MathNet.Numerics.dll"; "MathNet.Numerics.FSharp.dll" ]
// Web site location for the generated documentation
let website = "http://numerics.mathdotnet.com/docs"

// Specify more information about your project
let info =
  [ "project-name", "Math.NET Numerics"
    "project-author", "Christoph Ruegg, Marcus Cuda, Jurgen Van Gael"
    "project-summary", "Math.NET Numerics, providing methods and algorithms for numerical computations in science, engineering and every day use. .Net 4, .Net 3.5, SL5, Win8, WP8, PCL 47 and 136, Mono, Xamarin Android/iOS."
    "project-github", "http://github.com/mathnet/mathnet-numerics"
    "project-nuget", "http://nuget.com/packages/MathNet.Numerics" ]

// --------------------------------------------------------------------------------------
// For typical project, no changes are needed below
// --------------------------------------------------------------------------------------

#I "../../packages/FSharp.Compiler.Service.0.0.44/lib/net40"
#I "../../packages/RazorEngine.3.3.0/lib/net40/"
#r "../../packages/Microsoft.AspNet.Razor.2.0.30506.0/lib/net40/System.Web.Razor.dll"
#I "../../packages/FSharp.Formatting.2.4.4/lib/net40"
#r "../../packages/FAKE/tools/FakeLib.dll"
#r "FSharp.Compiler.Service.dll"
#r "RazorEngine.dll"
#r "FSharp.Literate.dll"
#r "FSharp.CodeFormat.dll"
#r "FSharp.MetadataFormat.dll"

open Fake
open System
open System.IO
open Fake.FileHelper
open FSharp.Literate
open FSharp.MetadataFormat

// When called from 'build.fsx', use the public project URL as <root>
// otherwise, use the current 'output' directory.
#if RELEASE
let root = website
#else
let root = "file://" + (__SOURCE_DIRECTORY__ @@ "../../out/docs")
#endif

// Paths with template/source/output locations
let top        = __SOURCE_DIRECTORY__ @@ "../../"
let bin        = __SOURCE_DIRECTORY__ @@ "../../out/lib/Net40"
let content    = __SOURCE_DIRECTORY__ @@ "../content"
let output     = __SOURCE_DIRECTORY__ @@ "../../out/docs"
let files      = __SOURCE_DIRECTORY__ @@ "../files"
let templates  = __SOURCE_DIRECTORY__ @@ "templates"
let formatting = __SOURCE_DIRECTORY__ @@ "../../packages/FSharp.Formatting.2.4.4/"
let docTemplate = formatting @@ "templates/docpage.cshtml"

// Where to look for *.csproj templates (in this order)
let layoutRoots =
    [ templates
      formatting @@ "templates"
      formatting @@ "templates/reference" ]

let extraDocs =
    [ "LICENSE.md", "License.md"
      "CONTRIBUTING.md", "Contributing.md"
      "CONTRIBUTORS.md", "Contributors.md" ]

let releaseNotesDocs =
    [ "RELEASENOTES.md", "ReleaseNotes.md", "Release Notes"
      "RELEASENOTES-Data.md", "ReleaseNotes-Data.md", "Data Extensions Release Notes"
      "RELEASENOTES-Native.md", "ReleaseNotes-Native.md", "Native Providers Release Notes" ]

// Copy static files and CSS + JS from F# Formatting
let copySupportFiles() =
    CopyRecursive files output true |> Log "Copying file: "
    ensureDirectory (output @@ "content")
    CopyRecursive (formatting @@ "styles") (output @@ "content") true |> Log "Copying styles and scripts: "

let copyExtraDocs() =
    for (fileName, docName) in extraDocs do CopyFile (content @@ docName) (top @@ fileName)

let prepareReleaseNotes() =
    for (fileName, docName, title) in releaseNotesDocs do
        String.concat Environment.NewLine
          [ "# " + title
            "[Math.NET Numerics](ReleaseNotes.html) | [Data Extensions](ReleaseNotes-Data.html) | [Native Providers](ReleaseNotes-Native.html)"
            ""
            ReadFileAsString (top @@ fileName) ]
        |> ReplaceFile (content @@ docName)

// Build API reference from XML comments
let buildReference() =
    CleanDir(output @@ "reference")
    for lib in referenceBinaries do
        MetadataFormat.Generate
            (bin @@ lib, output @@ "reference", layoutRoots, parameters = ("root", root) :: info,
             sourceRepo = "https://github.com/mathnet/mathnet-numerics/tree/master/src", sourceFolder = @"..\..\src",
             publicOnly = true)

// Build documentation from `fsx` and `md` files in `docs/content`
let buildDocumentation() =
    let subdirs = Directory.EnumerateDirectories(content, "*", SearchOption.AllDirectories)
    for dir in Seq.append [ content ] subdirs do
        let sub = if dir.Length > content.Length then dir.Substring(content.Length + 1) else "."
        Literate.ProcessDirectory
            (dir, docTemplate, output @@ sub, replacements = ("root", root) :: info, layoutRoots = layoutRoots,
             references = false, lineNumbers = true)

let cleanup() =
    for (_, docName) in extraDocs do DeleteFile (content @@ docName)
    for (_, docName, _) in releaseNotesDocs do DeleteFile (content @@ docName)

// Generate
copySupportFiles()
copyExtraDocs()
prepareReleaseNotes()
buildDocumentation()
buildDocumentation()
cleanup()
