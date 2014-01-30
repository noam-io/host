require 'rubygems'
require 'bundler'
Bundler.setup(:default, :release)
require 'releasy'

$LOAD_PATH << "./lib"
require 'releasy/noam_osx_app'

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

Releasy::Project.new do
  name "Noam"
  version "0.0.1"
  verbose

  executable "bin/noamweb"
  files ["bin/noamweb", "lib/**/*.rb", "web/**/*.*"]
  exposed_files "README.md"
  add_link "https://github.com/ideo/noam", "Noam Server code"
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

  add_build :noam_osx_app do
    url "com.ideo.noam_server"

    icon "Noam.icns"

    # After cloning & building https://github.com/trptcolin/ruby_app we expect
    # this wrapper to be the output of `tar -zcvf ruby-mac-wrapper-YYYY-MM-DD.tar.gz ./Ruby.app`
    # in that directory. The .tar.gz filename is flexible as long as it matches
    # between the actual file and this wrapper specification.
    wrapper "wrappers/ruby-mac-wrapper-2014-01-24.tar.gz"
    add_package :tar_gz
  end

  add_deploy :local # Only deploy locally (no rsync).
end
