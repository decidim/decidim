# frozen_string_literal: true

module Decidim
  module Admin
    # Updates the newsletter given form data.
    class UpdateNewsletter < Rectify::Command
      # Initializes the command.
      #
      # newsletter - The Newsletter to update.
      # form       - The form object containing the data to update.
      # user       - The user that updates the newsletter.
      def initialize(newsletter, form, user)
        @newsletter = newsletter
        @form = form
        @user = user
        @organization = user.organization
      end

      def call
        return broadcast(:invalid) unless @form.valid?
        return broadcast(:invalid) if @newsletter.sent?
        return broadcast(:invalid) unless @organization == @newsletter.organization

        @newsletter.update_attributes!(
          subject: @form.subject,
          body: @form.body,
          author: @user
        )

        broadcast(:ok, @newsletter)
      end
    end
  end
end
