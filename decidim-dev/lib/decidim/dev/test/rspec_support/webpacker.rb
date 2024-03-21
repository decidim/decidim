# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    raise "Rails.root directory does not exist" unless Rails.root.exist?
    raise "package.json file does not exist" unless Rails.root.join("package.json").exist?
    raise "Node modules directory does not exist" unless Rails.root.join("node_modules").exist?

    Dir.chdir(Rails.root) { Webpacker.compile }
  end
end
