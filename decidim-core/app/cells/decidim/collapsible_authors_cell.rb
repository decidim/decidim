# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of authors. Each element from the
  # array of Users will be rendered with the `:cell` cell.
  class CollapsibleAuthorsCell < Decidim::ViewModel
    MAX_ITEMS_STACKED = 3

    def show
      if options[:stack]
        return cell("decidim/redesigned_author", model.first, { skip_profile_link: true }.merge(options)) if model.length == 1

        return render :stack
      end

      return cell("decidim/redesigned_author", model.first, { layout: :compact }.merge(options)) if model.length == 1

      render
    end

    def visible_authors
      @visible_authors ||= model.take(MAX_ITEMS_STACKED)
    end
  end
end
