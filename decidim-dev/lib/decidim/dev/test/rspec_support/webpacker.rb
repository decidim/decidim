# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all) do
    raise "Rails.root directory does not exist" unless Rails.root.exist?
    raise "package.json file does not exist" unless Rails.root.join("package.json").exist?
    raise "Node modules directory does not exist" unless Rails.root.join("node_modules").exist?

    Dir.chdir(Rails.root) { Shakapacker.compile }
  rescue Errno::ENOENT
    node_modules_contents = `ls #{Rails.root.join("node_modules")}`

    message = <<~ERROR
      There was an error during the Webpacker compilation
      #{"=" * 80}
      Node version: #{`node -v`}
      #{"=" * 80}
      NPM version: #{`npm -v`}
      #{"=" * 80}
      Node modules packages: #{`npm list`}
      #{"=" * 80}
      Node modules contents: #{node_modules_contents}
      #{"=" * 80}
    ERROR

    raise message
  end
end
