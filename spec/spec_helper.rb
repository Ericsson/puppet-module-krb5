RSpec.configure do |config|
  config.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|
  config.before :each do
    Puppet[:parser] = 'future' if ENV['PARSER'] == 'future'
  end
  config.default_facts = {
    osfamily: 'RedHat',
  }
end
