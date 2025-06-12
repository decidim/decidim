# frozen_string_literal: true

module Decidim
  module Debates
    module AdminLog
      module ValueTypes
        # This class presents the given value as a Decidim::Debates::DebateTitleBody. Check
        # the `DefaultPresenter` for more info on how value presenters work.
        class DebateTitleDescriptionPresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value

            renderer = Decidim::ContentRenderers::BlobRenderer.new(h.decidim_escape_translated(value))
            renderer.render(links: false).html_safe
          end
        end
      end
    end
  end
end
