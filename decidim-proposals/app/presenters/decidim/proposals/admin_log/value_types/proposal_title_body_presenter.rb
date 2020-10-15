# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      module ValueTypes
        class ProposalTitleBodyPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          include Decidim::TranslatableAttributes

          def present
            return unless value

            translated_value = translated_attribute(value)
            return if translated_value.blank?

            renderer = Decidim::ContentRenderers::HashtagRenderer.new(translated_value)
            renderer.render(links: false).html_safe
          end
        end
      end
    end
  end
end
