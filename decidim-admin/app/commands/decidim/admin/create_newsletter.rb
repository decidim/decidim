# frozen_string_literal: true

module Decidim
  module Admin
    # Creates a newsletter and assigns the right author and
    # organization.
    class CreateNewsletter < Rectify::Command
      # Initializes the command.
      #
      # form - The source fo data for this newsletter.
      # user - The User that authored this newsletter.
      def initialize(form, user)
        @form = form
        @user = user
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        newsletter = Newsletter.create!(
          subject: @form.subject,
          body: @form.body,
          author: @user,
          organization: @user.organization
        )

        broadcast(:ok, newsletter)
      end
    end
  end
end
