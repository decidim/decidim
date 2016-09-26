# frozen_string_literal: true
module Decidim
  module Admin
    # Custom application mailer, scoped to the admin mailer.
    #
    class ApplicationMailer < ActionMailer::Base
      default from: "from@example.com"
      layout "mailer"
    end
  end
end
