# frozen_string_literal: true

module Decidim
  module Proposals
    module Concerns
      module FormattedAttributes
        extend ActiveSupport::Concern
        included do
          def formatted_title
            title.capitalize
          end

          def formatted_body
            body.capitalize
          end
        end
      end
    end
  end
end
