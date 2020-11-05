# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of authors. Each element from the
  # array of Users will be rendered with the `:cell` cell.
  #
  # Available sizes:
  #  - any number from 1 to 12
  #  - default value is 3
  #  - it is delegated to the `decidim/collapsible_list` cell
  #
  # Example:
  #
  #    cell(
  #      "decidim/collapsible_authors",
  #      list_of_authors,
  #      cell_name: "my/cell",
  #      cell_options: { my: :options },
  #      hidden_elements_count_i18n_key: "my.custom.key",
  #      size: 3
  #    )
  class CollapsibleAuthorsCell < CollapsibleListCell
    include CellsHelper

    private

    def actionable?
      return false if options[:has_actions] == false

      true if withdrawable? || flaggable?
    end
  end
end
