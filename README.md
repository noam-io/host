# Noam Server
======================================
Brains of the Noam system

## Prerequisites

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


## Running unit tests

### Ruby
- `bundle exec rspec`: skips integration tests like the Riak ones, since they require a running riak server
- `bundle exec rspec --tag integration`: runs only integration tests (described above)
- `bundle exec rspec -O .rspec-no-tags`: runs all tests, including integration ones

### JavaScript
- `rake jasmine`: starts a jasmine server on http://0.0.0.0:8888 - browse to it to run tests

## Building for distribution (OSX)

* Use Ruby 2.1.0 (this *might* not be necessary, but is probably safest because of native gems, to match the Ruby version we bundle)
* Download the tar.gz archive at https://github.com/trptcolin/ruby_app/releases/tag/0.0.1-em
  - This is just a thin wrapper around a statically-compiled Ruby with EventMachine and Thin native gem dependencies bundled. Don't bother to un-tar it, just download the archive (or build it yourself via the directions in that repo).
* Copy that .tar.gz archive into `./wrappers` (creating that directory if necessary)
* Run `rake installer:osx` - this will unpack the .tar.gz, insert all the Noam-specific code, and build an installer at `./pkg/Noam.pkg`
* NOTE: Adding new native gems (depending on what native dependencies they have) or upgrading Ruby will require changes to the ruby_app project.
