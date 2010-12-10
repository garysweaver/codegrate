Codegrate
=====

Codegrate is a Rails 3 web application that analyzes source code management repositories (only Git currently, but may add more types later) and stores scores based on diffs per developer commit (each + or - found in the diff adds to the score of that commit, so it is similar to a LOC delta, but refactoring/changes to lines actually weigh more than new code or removal of code). It isn't a perfect scoring system but it's just a first attempt to measure developer productivity simply by just looking at their work artifacts. It uses a scheduler to update repositories in the background.

Installation
=====

Unfortunately, this is going to be sparse for now until I have more time to work on it.

First install Git, Ruby, and Rails 3.

Then, get the project from GitHub, and in the project directory create the database and migrate as usual (by default it uses SQLite). Be warned that in the current version it puts repositories in ./repos and blows away those clones and the analytics tables in the DB on each run. For this reason, please consider it alpha software and subject to change.

When you do db migrate be sure to do this or the initializer that updates the analytics at startup will fail:

    NOINIT=1 rake db:migrate

Contribute
=====

Please fork this project and contribute back as much as you want, or let me know you're serious and you can be a committer.

### License

Copyright (c) 2010 Gary S. Weaver, released under the [MIT license][lic].

[lic]: http://github.com/garysweaver/codegrate/blob/master/LICENSE

