# frozen_string_literal: true

module Decidim
  module System
    # Updates the OAuth application given form data.
    class UpdateOAuthApplication < Rectify::Command
      # Initializes the command.
      #
      # application - The OAuthApplication to update.
      # form        - The form object containing the data to update.
      # user        - The user that updates the application.
      def initialize(application, form, user)
        @application = application
        @form = form
        @user = user
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        @application = Decidim.traceability.update!(
          @application,
          @user,
          name: @form.name,
          decidim_organization_id: @form.decidim_organization_id,
          organization_name: @form.organization_name,
          organization_url: @form.organization_url,
          organization_logo: @form.organization_logo,
          redirect_uri: @form.redirect_uri
        )

        broadcast(:ok, @application)
      rescue ActiveRecord::RecordInvalid
        @form.errors.add(:organization_logo, @application.errors[:organization_logo]) if @application.errors.include? :organization_logo
        broadcast(:invalid)
      end
    end
  end
end
