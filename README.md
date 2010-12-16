Codegrate
=====

Codegrate is a Rails 3 web application to score, summarize, and graphically report commit data across version control/SCM repositories. Currently only Git repositories are supported, but if you'd like to add others, please fork it and send a pull request.

Codegrate provides a web-based UI to view a dashboard (with graph courtesy of [open flash chart][ofc]), a place to add/remove/edit repositories used by Codegrate, information about authors in the analyzed repositories, and a list of all known commits and their scores.

How It Works
=====

When a repository is added/edited or on startup, a request is added to analyze the repository.

Using [rufus scheduler][rsc], every 5 seconds, repositories in queue are analyzed in sequence. On startup and every 30 minutes, all repositories are requested to be analyzed.

Repository analyzation first involves calling git clone from shell. This is faster than [GRIT][grit]'s clone, even with the latest changes in the exec-direct branch. If you want to use GRIT's clone, you can set the RCLONE env variable to anything (e.g. RCLONE=1 rails server).

The next step in analyzation is calling the log method on GRIT's git repo and using the following algorithm to determine a score for each commit: score = (number of LOC additions) + (number of LOC removals) + (number of LOC removals greater than number of LOC additions, if any). The score is limited to 150 per commit to attempt to avoid issues with high scores due to addition and removal of image files, etc.

To Do
=====

Add any of these as issues in the tracker or anything else you can think of. I won't necessarily get to it, though.

More important items first:

* Currently the request is using a fairly inefficient method of calculating the score for each day. The plan is for it to do this during the analysis and store in summary tables. This makes it almost unusable for most repositories, unless you have a very fast server.
* It deletes data and reanalyzes too much. Shouldn't clone unless needed (should just pull).
* Obviously more control over the reporting (specify date range, compare weeks, months, etc. and not just days), more reports (by repo, by branch).
* Should add authentication (require login) and authorization (roles), especially if using repos that require authN to access.
* Should possibly not just clone/analyze master branch. Could get list of all remote branches and score all.
* Should make reports printable.
* Should provide reports as PDF. This may require using something other than open flash chart, even though it could export images, so it could work.
* Could make it store diffs and allow users to review code, at the very least just storing the username of the person who looked at the diff. Also, could have a way to auto-notify team if changes are made that require review (yes, that would be better as a SCM hook, but...). And you'd need a way to mark code as reviewed in mass without defining who reviewed.

Installation
=====

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