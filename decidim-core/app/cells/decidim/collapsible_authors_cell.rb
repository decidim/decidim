# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of authors. Each element from the
  # array of Users will be rendered with the `:cell` cell.
  class CollapsibleAuthorsCell < Decidim::ViewModel

    MAX_ITEMS_STACKED = 3

    def show
      render
    end

    def visible_authors
      @visible_authors ||= model.take(MAX_ITEMS_STACKED)
    end
  end
end
