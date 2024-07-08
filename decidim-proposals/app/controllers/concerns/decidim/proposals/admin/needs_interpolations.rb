# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    module Admin
      module NeedsInterpolations
        extend ActiveSupport::Concern

        included do
          def populate_interpolations(text, proposal)
            text.to_h do |language, value|
              value = value.gsub("%{organization}", translated_attribute(proposal.organization.name))
              value = value.gsub("%{name}", author_name(proposal))
              value = value.gsub("%{admin}", current_user.name)

              [language, value]
            end
          end

          def author_name(proposal)
            name = proposal.creator_author.try(:title) || proposal.creator_author.try(:name)
            name.is_a?(Hash) ? translated_attribute(name) : name
          end
        end
      end
    end
  end
end
