# frozen_string_literal: true

module Decidim
  # Helper related to the component setting :rich_editor_public_view.
  module RichTextEditorHelper
    def self.included(base)
      base.include Decidim::SanitizeHelper
    end

    def rich_text_editor_enabled?
      controller&.current_component&.settings.try(:rich_editor_public_view) == true
    end

    def text_editor_for(form, attribute, options = {})
      if rich_text_editor_enabled?
        options[:lines] ||= 25
        form.editor attribute, options
      else
        options[:rows] ||= 10
        form.text_area attribute, options
      end
    end
  end
end
