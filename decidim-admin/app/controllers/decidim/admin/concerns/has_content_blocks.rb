# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasContentBlocks
        extend ActiveSupport::Concern

        included do
          helper_method :content_blocks?

          private

          def content_blocks?
            return unless Decidim.page_blocks.include?(scoped_resource.try(:slug))

            @has_content_blocks ||= available_manifests.present?
          end
        end
      end
    end
  end
end
