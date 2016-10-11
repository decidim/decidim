# frozen_string_literal: true
module Decidim
  # Main application mailer configuration. Inherit from this to create new
  # mailers.
  class ApplicationMailer < ActionMailer::Base
    include Roadie::Rails::Automatic

    default from: "from@example.com"
    layout "mailer"
  end
end
