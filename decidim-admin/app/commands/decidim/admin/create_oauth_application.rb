# frozen_string_literal: true

module Decidim
  module Admin
    # Creates an OAuthApplication.
    class CreateOAuthApplication < Rectify::Command
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
          name: @form.name,
          organization_name: @form.organization_name,
          organization_url: @form.organization_url,
          organization_logo: @form.organization_logo,
          redirect_uri: @form.redirect_uri,
          scopes: "public",
          organization: @form.current_organization
        )

        broadcast(:ok, @application)
      rescue ActiveRecord::RecordInvalid
        @form.errors.add(:organization_logo, @application.errors[:organization_logo]) if @application.errors.include? :organization_logo
        broadcast(:invalid)
      end
    end
  end
end
