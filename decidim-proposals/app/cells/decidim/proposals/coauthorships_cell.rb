# frozen_string_literal: true

module Decidim
  module Proposals
    # This cell renders a collapsible list of the proposal coauthors.
    #
    # Available sizes:
    #  - `:small` => collapses after 3 elements.
    #  - `:default` => collapses after 7 elements. If not specified, this one is
    #    used.
    #
    # Example:
    #
    #    cell("decidim/proposals/coauthorships", @proposal)
    class CoauthorshipsCell < Decidim::ViewModel
      include Decidim::ApplicationHelper

      def show
        if model.official?
          cell "decidim/author", present(model).author, from: model
        else
          cell(
            "decidim/collapsible_authors",
            authors_for(model),
            cell_name: "decidim/author",
            cell_options: { extra_classes: ["author-data--small"] },
            size: :small,
            from: model
          )
        end
      end

      private

      def authors_for(coauthorable)
        coauthorable.identities.map { |identity| present(identity) }
      end
    end
  end
end
