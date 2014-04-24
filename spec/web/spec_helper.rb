$: << File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'web'))

require 'hacks/em_patches'
require 'em/pure_ruby'
require 'timeout'

require 'rack/test'
require 'noam_web'
require 'thin'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app; NoamApp; end
end

RSpec.configure { |config| config.include(RSpecMixin) }
