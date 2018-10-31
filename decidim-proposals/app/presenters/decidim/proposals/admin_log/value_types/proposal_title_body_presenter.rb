# frozen_string_literal: true

module Decidim
  module Proposals
    module AdminLog
      module ValueTypes
        class ProposalTitleBodyPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value
            renderer = Decidim::ContentRenderers::HashtagRenderer.new(value)
            renderer.render_without_link.html_safe
          end
        end
      end
    end
  end
end
