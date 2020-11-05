# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResourceMailer < ApplicationMailer
      def fake_mail(user, organization)
        @user = user
        @organization = organization

        mail(to: "#{user.name} <#{user.email}>") do |format|
          format.text { "This is the test" }
          format.html { "<p>This is a mail </p>" }
        end
      end
    end
  end
end
