# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of authors. Each element from the
  # array of Users will be rendered with the `:cell` cell.
  class CollapsibleAuthorsCell < Decidim::ViewModel
    MAX_ITEMS_STACKED = 3

    def show
      return cell("decidim/author", model.first, single_author_options.merge(options)) if model.length == 1
      return render :stack if options[:stack]

      render
    end

    def single_author_options
      options[:stack] ? { skip_profile_link: true } : { layout: :compact }
    end

    def visible_authors
      @visible_authors ||= model.take(MAX_ITEMS_STACKED)
    end
  end
end
