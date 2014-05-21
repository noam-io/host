#Copyright (c) 2014, IDEO

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

NOAM_VERSION = "0.2.1"
NOAM_OSX_ID = "com.ideo.noam_server"
NOAM_OSX_APP_NAME = "Noam"

Releasy::Project.new do
  name NOAM_OSX_APP_NAME
  version NOAM_VERSION
  verbose

  executable "bin/noamweb"
  files ["bin/noamweb", "config/**/*", "lib/**/*.rb", "web/**/*.*"]
  exposed_files []
  add_link "https://github.com/ideo/noam", "Noam Server code"
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

  add_build :noam_osx_app do
    gemspecs Bundler.definition.specs_for([:default, :mongo]).to_a

    url NOAM_OSX_ID
    icon "Noam.icns"

    # After cloning & building https://github.com/trptcolin/ruby_app we expect
    # this wrapper to be the output of `tar -zcvf ruby-mac-wrapper-YYYY-MM-DD.tar.gz ./Ruby.app`
    # in that directory. The .tar.gz filename is flexible as long as it matches
    # between the actual file and this wrapper specification.
    wrapper "wrappers/ruby-mac-wrapper-2014-02-11.tar.gz"
    add_package :tar_gz
  end

  add_deploy :local # Only deploy locally (no rsync).
end

namespace :installer do
  desc "Create OSX Installer for Noam"
  task :osx => ["build:noam:osx:app"] do
    version = NOAM_VERSION
    folder_containing_app = "./pkg/noam_#{version.gsub(".", "_")}_OSX"
    # NOTE: Once we need to run scripts, the --scripts flag lets us specify a
    # scripts directory for bash scripts named things like preflight,
    # postflight, etc. to run at those times.
    system %[pkgbuild --root "#{folder_containing_app}/#{NOAM_OSX_APP_NAME}.app" \\
                      --install-location "/Applications/#{NOAM_OSX_APP_NAME}.app" \\
                      --version #{version} \\
                      --identifier #{NOAM_OSX_ID} \\
                      ./pkg/#{NOAM_OSX_APP_NAME}.pkg]

  end
end
