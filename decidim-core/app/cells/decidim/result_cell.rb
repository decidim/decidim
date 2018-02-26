# frozen_string_literal: true

module Decidim
  class ResultCell < Decidim::ViewModel
    #include LayoutHelper

    def show
      cell(model.resource.class.model_name.i18n_key, model.resource)
      # render
    end

    private

    def resource_type
      model.class.model_name.human
    end

    def resource_path
      resource_locator(model).path
    end

  end
end
