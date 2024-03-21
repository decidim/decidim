# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    Dir.chdir(Rails.root) { Webpacker.compile }
  end
end
