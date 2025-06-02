# frozen_string_literal: true

module Decidim
  module Admin
    # A command with all the business logic for updating the current
    # organization appearance.
    class UpdateOrganizationAppearance < Decidim::Commands::UpdateResource
      private

      def attributes
        super
          .delete_if { |_k, val| val.is_a?(Decidim::ApplicationUploader) }
          .tap do |attributes|
            attributes[:header_snippets] = form.header_snippets if Decidim.enable_html_header_snippets
          end
      end
    end
  end
end
