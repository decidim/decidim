# frozen_string_literal: true

module Decidim
  class SoftDeleteResourceEvent < Decidim::Events::SimpleEvent
    i18n_attributes :resource_type, :resource_title

    def resource_type
      resource.model_name.human
    end

    def resource_title
      translated_attribute resource.title
    end
  end
end
