# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:all, type: :system) do
    Dir.chdir(Rails.root) { Webpacker.compile }
  end
  config.before(:all, type: :mailer) do
    Dir.chdir(Rails.root) { Webpacker.compile }
  end
end
