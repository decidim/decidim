# frozen_string_literal: true

module Decidim
  module CellsPaginateHelper
    include Kaminari::Helpers::HelperMethods
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TranslationHelper
    include Cell::ViewModel::Partial
    include Decidim::PaginateHelper

    def paginate(scope, **options, &)
      options = options.reverse_merge(views_prefix: "../views/")
      super
    end

    def per_page
      params[:per_page] || Decidim::Paginable::OPTIONS.first
    end
  end
end
