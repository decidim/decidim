# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceMailer < ApplicationMailer
      def send_email(user, organization, subject, reply_to)
        @user = user
        @organization = organization

        args = { to: "#{user.name} <#{user.email}>" }
        args[:subject] = subject if subject
        args[:reply_to] = reply_to if reply_to

        mail(
          args
        ) do |format|
          format.text { "This is the test" }
          format.html { "<p>This is a mail </p>" }
        end
      end
    end
  end
end
