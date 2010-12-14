Codegrate
=====

Codegrate is a Rails 3 web application to score, summarize, and graphically report commit data across version control/SCM repositories. Currently only Git repositories are supported, but if you'd like to add others, please fork it and send a pull request.

Codegrate provides a web-based UI to view a dashboard (with graph courtesy of [open flash chart][ofc]), a place to add/remove/edit repositories used by Codegrate, information about authors in the analyzed repositories, and a list of all known commits and their scores.

When a repository is added, Codegrate analyzes the repository. This involves calling git clone from shell, because it is faster than [GRIT][grit]'s clone (I even tried the exec-direct branch), but if you want to use GRIT's clone, you can set the RCLONE env variable to anything (e.g. RCLONE=1 rails server). Then it calls the log method on GRIT's git repo and uses the following algorithm to determine a score for each commit: score = (number of LOC additions) + (number of LOC removals) + (number of LOC removals greater than number of LOC additions, if any). This is by no means a perfect scoring system, in fact it is quite horrid, but I wanted something that could be applied across all kinds of code. Basically, the theory is that if you are just adding code you are doing something (and you get a big score for reusing someone else's code), but refactoring is more complex (code changes that involve additions and subtractions), and reducing code should be rewarded (since potentially it implies less complexity and less required maintenance). There are many ways this scoring system could be easily abused, but it at least tries to measure productivity at some level.

In addition to using open flash chart and GRIT, it uses the [rufus scheduler][rsc] to keep information up-to-date.

Installation
=====

Unfortunately, this is going to be sparse for now until I have more time to work on it.

First install Git, Ruby, and Rails 3.

Then, get the project from GitHub, and in the project directory create the database and migrate as usual (by default it uses SQLite). Be warned that in the current version it puts repositories in ./repos and blows away those clones and the analytics tables in the DB on each run. Please consider it alpha software and subject to change.

Create the database:

    rake db:create

When you do db migrate be sure to do this or the initializer that updates the analytics at startup will fail:

    NOINIT=1 rake db:migrate

Then start it:

    rails server

Then go to [http://localhost:3000/][localhost] to use it.

Contribute
=====

Please fork this project and contribute back as much as you want via pull requests.

### License

Copyright (c) 2010 Gary S. Weaver, released under the [MIT license][lic].

[lic]: http://github.com/garysweaver/codegrate/blob/master/LICENSE
[ofc]: https://github.com/galetahub/open_flash_chart
[grit]: https://github.com/mojombo/grit
[rsc]: http://rufus.rubyforge.org/rufus-scheduler/
[localhost]: http://localhost:3000/