# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasContentBlocks
        extend ActiveSupport::Concern

        included do
          helper_method :content_blocks?

          private

          ACCEPTED_SLUGS = %w(terms-and-conditions).freeze

          def content_blocks?
            return unless ACCEPTED_SLUGS.include?(scoped_resource&.slug)

            @has_content_blocks ||= available_manifests.present?
          end
        end
      end
    end
  end
end
