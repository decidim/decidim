# frozen_string_literal: true

module Decidim
  module System
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
          decidim_organization_id: @form.decidim_organization_id,
          redirect_uri: @form.redirect_uri,
          scopes: "public"
        )

        broadcast(:ok, @application)
      end
    end
  end
end
