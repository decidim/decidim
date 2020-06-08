# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Templates
    # A concern with the components needed when you want to create templates for a model
    module Templatable
      extend ActiveSupport::Concern

      included do
        has_one :template,
                class_name: "Decidim::Templates::Template",
                dependent: :destroy,
                inverse_of: :templatable,
                as: :templatable
      end
    end
  end
end
