# frozen_string_literal: true

module Decidim
  class ResultCell < Decidim::ViewModel
    #include LayoutHelper

    def show
      #raise
      cell(model.resource.class.model_name.i18n_key, model.resource)
      #render
    end

  end
end
