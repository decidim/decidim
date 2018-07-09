# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of authors. Each element from the
  # array of Users will be rendered with the `:cell` cell.
  #
  # Available sizes:
  #  - `:small` => collapses after 3 elements.
  #  - `:default` => collapses after 7 elements. If not specified, this one is
  #    used.
  #
  # Example:
  #
  #    cell(
  #      "decidim/collapsible_authors",
  #      list_of_authors,
  #      cell_name: "my/cell",
  #      cell_options: { my: :options },
  #      hidden_elements_count_i18n_key: "my.custom.key",
  #      size: :small
  #    )
  class CollapsibleAuthorsCell < CollapsibleListCell
    include CellsHelper

    private

    def actionable?
      return false if options[:has_actions] == false
      true if withdrawable? || flagable?
    end
  end
end
