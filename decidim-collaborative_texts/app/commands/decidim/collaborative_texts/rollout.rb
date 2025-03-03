# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This command is executed when the user creates a Document from the admin
    # panel.
    class Rollout < Decidim::Commands::CreateResource
      fetch_form_attributes :body, :document, :draft

      private

      def resource_class = Decidim::CollaborativeTexts::Version
    end
  end
end
