# frozen_string_literal: true

module Decidim
  module System
    # Creates an OAuthApplication.
    class CreateOAuthApplication < Decidim::Command
      # Initializes the command.
      #
      # form - The source fo data for this OAuthApplication.
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) unless @form.valid?

        @application = Decidim.traceability.create!(
          OAuthApplication,
          @form.current_user,
          **oauth_application_attributes
        )

        broadcast(:ok, @application)
      rescue ActiveRecord::RecordInvalid
        @form.errors.add(:organization_logo, @application.errors[:organization_logo]) if @application.errors.include? :organization_logo
        broadcast(:invalid)
      end

      def oauth_application_attributes
        {
          organization: @form.current_organization,
          name: @form.name,
          decidim_organization_id: @form.decidim_organization_id,
          organization_name: @form.organization_name,
          organization_url: @form.organization_url,
          organization_logo: @form.organization_logo,
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
