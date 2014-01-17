# Noam Server
======================================
Brains of the Noam system

## Prerequesits

* Install the XCode "Command Line Tools" from [apple](https://developer.apple.com/downloads/index.action).
  You'll have to register with your Apple Id.  You can downlaod and install the full version of xCode, but
  it is 20x larger than the command line tools.

* Install [RVM](https://rvm.io/) (Ruby Version Manager) and the latest ruby.

        \curl -L https://get.rvm.io | bash -s stable --ruby

* Install git from [Git-Scm](http://git-scm.com/downloads)

## Running this app

* clone this repository

        git clone https://github.com/ideo/noam.git

* cd (change directory) to this repository

        cd noam

* Install bundler gem

        gem install bundler

*  Install gem bundle

        bundle install

*  Start server

        bundle exec bin/noamweb

* browse to http://localhost:8081 with Chrome or Safari

## Building for distribution

* Prerequisite
  - clone and build https://github.com/trptcolin/ruby_app following the steps in its README

* Once the .tar.gz archive described in `Rakefile` (on this project) is in
  place, `rake build:noam:osx:app` will inject the NoamServer code into the
  base .app. Adding new native gems or upgrading Ruby will require changes to
  the ruby_app project.
