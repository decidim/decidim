# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      module ValueTypes
        class ProposalTitleBodyPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value

            translated_value = h.decidim_escape_translated(value)
            return if translated_value.blank?
          end
        end
      end
    end
  end
end
