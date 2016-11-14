# frozen_string_literal: true
module Decidim
  module Pages
    class ApplicationMailer < ActionMailer::Base
      default from: "from@example.com"
      layout "mailer"
    end
  end
end
