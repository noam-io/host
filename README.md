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

        git clone https://github.com/noam-io/host

* cd (change directory) to this repository

        cd host

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
* Download the tar.gz archive at https://github.com/trptcolin/ruby_app/releases/tag/0.0.3-em
  - This is just a thin wrapper around a statically-compiled Ruby with EventMachine and Thin native gem dependencies bundled. Don't bother to un-tar it, just download the archive (or build it yourself via the directions in that repo).
* Copy that .tar.gz archive into `./wrappers` (creating that directory if necessary)
* Run `rake installer:osx` - this will unpack the .tar.gz, insert all the Noam-specific code, and build an installer at `./pkg/Noam.pkg`
* NOTE: Adding new native gems (depending on what native dependencies they have) or upgrading Ruby will require changes to the ruby_app project.

## Developing a Lemma

There is a script to verify the implementation of Noam lemmas. The script starts a mock Noam server with the room name of `lemma_verification` and waits for lemmas to connect to it. Once a lemma connects to the room, tests will be run against the lemma.

### Registering for Verification Tests

Since different lemmas support different features, the lemma is responsible for registering for the tests it wants to be executed.

There is one event name per test, so the lemma will register for each event name that it implements. e.g. `Echo`

### Executing Verification Tests

A test is executed by sending a message to the lemma, having the lemma send a response and making assertions around the returned value.

Available tests can be found in `lemma_verification/tests`.

An example using the `LemmaVerification::Tests::Echo` test:

 * The lemma registers for "Echo" messages.
 * The mock server sends an event named "Echo" with a dynamically generated event value to the lemma.
 * The lemma sends a message named "EchoVerify" to the server
 * The mock server asserts that the value returned is the original value sent.
