# frozen_string_literal: true

module Decidim
  module Proposals
    module Concerns
      module FormattedAttributes
        extend ActiveSupport::Concern
        included do
          def formatted_title
            title.titleize
          end

          def formatted_body
            body.titleize
          end
        end
      end
    end
  end
end
