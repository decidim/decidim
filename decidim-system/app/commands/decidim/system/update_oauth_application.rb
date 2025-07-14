# frozen_string_literal: true

module Decidim
  module System
    # Updates the OAuth application given form data.
    class UpdateOAuthApplication < Decidim::Command
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
          **oauth_application_attributes
        )

        broadcast(:ok, @application)
      rescue ActiveRecord::RecordInvalid
        @form.errors.add(:organization_logo, @application.errors[:organization_logo]) if @application.errors.include? :organization_logo
        broadcast(:invalid)
      end

      def oauth_application_attributes
        {
          name: @form.name,
          decidim_organization_id: @form.decidim_organization_id,
          organization_name: @form.organization_name,
          organization_url: @form.organization_url,
          redirect_uri: @form.redirect_uri,
          scopes: @form.scopes.join(" "),
          confidential: @form.confidential?,
          refresh_tokens_enabled: @form.refresh_tokens_enabled?
        }.tap do |attrs|
          attrs[:organization_logo] = @form.organization_logo if @form.organization_logo.present?
        end
      end
    end
  end
end
