# StatusCast

An embarassingly simple client for Socialcast, written in Macruby

Copyright (C) 2011, Riccardo Cambiassi
Licensed under BSD Opensource License.

Use at your own risk: this is nowhere near complete (see TODO below) and suffers from alpha status poor performance.
However I found it a fun and useful exercise to learn a thing or two about Macruby.

## INSTALLATION

For the time being you'll need macruby and the bundler gem in order to setup the project properly without losing your sanity.

* copy socializer.yml.example to socializer.yml, open it in your favourite editor and fill in the blanks.
* make sure your bundle is up to date:

    `# cd StatusCast`
    
    `# bundle install`

* open the project in XCode, compile, run/deploy.

## TODO

* refactor socialcast api into its own gem
* add preferences panel
* move to asynchronous API requests
* add content filters
* let the messages be of arbitrary size
* add message (un)like action
* add message comments display
* add message commenting action
* add message edit/delete actions

