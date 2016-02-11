require 'simplecov'
require 'webmock/rspec'
require 'fileutils'

SimpleCov.start { add_filter 'spec' }
WebMock.disable_net_connect!

RSpec.configure do |config|
  tmpdir = File.expand_path('./tmp', File.dirname(__FILE__))

  config.before(:each) { FileUtils.mkdir_p(tmpdir) }
  config.after(:each)  { FileUtils.rm_rf(tmpdir) }
end

RSpec.configure do |config|
  config.before(:each) do
    p = File.expand_path('fixtures/*', File.dirname(__FILE__))
    h = Dir.glob(p).map { |s| [File.basename(s), File.open(s)] }.flatten
    @example_files = Hash[*h]
  end

  config.after(:each) do
    @example_files.each do |_n, f|
      f.close unless f.closed?
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'formdata'
