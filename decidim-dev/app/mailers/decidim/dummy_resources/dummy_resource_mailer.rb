# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceMailer < ApplicationMailer
      def send_email(user, organization, subject, reply_to)
        @user = user
        @organization = organization

        hash = { to: "#{user.name} <#{user.email}>" }
        hash[:subject] = subject if subject
        hash[:reply_to] = reply_to if reply_to

        mail(
          hash
        ) do |format|
          format.text { "This is the test" }
          format.html { "<p>This is a mail </p>" }
        end
      end
    end
  end
end
