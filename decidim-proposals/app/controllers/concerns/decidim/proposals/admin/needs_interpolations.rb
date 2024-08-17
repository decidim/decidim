# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    module Admin
      module NeedsInterpolations
        extend ActiveSupport::Concern

        included do
          def populate_interpolations(text, proposal)
            return populate_string_interpolations(text, proposal) if text.is_a?(String)

            populate_hash_interpolations(text, proposal)
          end

          def populate_hash_interpolations(hash, proposal)
            return hash unless hash.is_a?(Hash)

            hash.transform_values do |value|
              populate_interpolations(value, proposal)
            end
          end

          def populate_string_interpolations(value, proposal)
            value = value.gsub("%{organization}", translated_attribute(proposal.organization.name))
            value = value.gsub("%{name}", author_name(proposal))
            value.gsub("%{admin}", current_user.name)
          end

          def author_name(proposal)
            name = proposal.creator_author.try(:title) || proposal.creator_author.try(:name)
            translated_attribute(name)
          end
        end
      end
    end
  end
end
