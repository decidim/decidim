# frozen_string_literal: true

module Decidim
  module CellsPaginateHelper
    include Kaminari::Helpers::HelperMethods
    include ActionView::Helpers::OutputSafetyHelper
    include ActionView::Helpers::TranslationHelper
    include Cell::ViewModel::Partial
    include Decidim::PaginateHelper

    def paginate(scope, options = {}, &block)
      options = options.reverse_merge(views_prefix: "../views/")
      super
    end
  end
end
