# frozen_string_literal: true

module Decidim
  # This cell renders a generic button.
  class ButtonCell < Decidim::ViewModel
    include LayoutHelper
    include IconHelper
    include Decidim::SanitizeHelper
    include Decidim::ResourceHelper

    DEFAULT_ATTRIBUTES = {
      button_classes: "button button__sm button__transparent-secondary",
      text_classes: nil,
      icon_classes: nil,
      method: nil,
      remote: false,
      html_options: {}
    }.freeze

    def show
      render
    end

    def button_attributes
      @button_attributes ||= model || {}
    end

    private

    DEFAULT_ATTRIBUTES.each do |key, default_classes|
      define_method(key) do
        options[key] || default_classes
      end
    end

    def path
      button_attributes[:path]
    end

    def text
      button_attributes[:text]
    end

    def icon_name
      button_attributes[:icon]
    end
  end
end
