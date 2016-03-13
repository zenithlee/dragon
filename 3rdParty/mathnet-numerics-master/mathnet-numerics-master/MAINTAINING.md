Maintaining Math.NET Numerics
=============================

*Note: This document is only relevant for the maintainers of this project*

When creating a new release
---------------------------

- Update RELEASENOTES file with relevant changes, attributed by contributor (if external). Set date.
- Update CONTRIBUTORS file (via `git shortlog -sn`)

- buildn.sh All release

- Commit and push release notes and (auto-updated) assembly info files with new "Release: v1.2.3" commit

- buildn.sh PublishDocs
- buildn.sh PublishApi
- buildn.sh PublishTag
- buildn.sh PublishMirrors
- buildn.sh PublishNuGet

- Create new Codeplex and GitHub release, attach Zip files

Misc:

- Consider a tweet via [@MathDotNet](https://twitter.com/MathDotNet)
- Consider a post to the [Google+ site](https://plus.google.com/112484567926928665204)
- Update Wikipedia release version+date for the [Math.NET Numerics](http://en.wikipedia.org/wiki/Math.NET_Numerics) and [Comparison of numerical analysis software](http://en.wikipedia.org/wiki/Comparison_of_numerical_analysis_software) articles.
