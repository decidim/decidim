# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of a model's coauthors.
  #
  # Available sizes:
  #  - `:small` => collapses after 3 elements.
  #  - `:default` => collapses after 7 elements. If not specified, this one is
  #    used.
  #
  # Example:
  #
  #    cell("decidim/coauthorships", @proposal)
  class CoauthorshipsCell < Decidim::ViewModel
    include Decidim::ApplicationHelper

    def show
      if model.respond_to?(:official?) && model.official?
        cell "decidim/author", present(model).author, has_actions: has_actions?, from: model
      else
        cell(
          "decidim/collapsible_authors",
          authors_for(model),
          cell_name: "decidim/author",
          cell_options: { extra_classes: ["author-data--small"] },
          size: :small,
          from: model,
          has_actions: has_actions?
        )
      end
    end

    private

    def authors_for(coauthorable)
      coauthorable.identities.map { |identity| present(identity) }
    end

    def has_actions?
      return false if options[:has_actions] == false
      true
    end
  end
end
