# frozen_string_literal: true

module Decidim
  # Helper related to organization' setting :rich_text_editor_in_public_views.
  module RichTextEditorHelper
    def self.included(base)
      base.include Decidim::SanitizeHelper
    end

    delegate :rich_text_editor_in_public_views?, to: :current_organization

    def text_editor_for(form, attribute, options = {})
      if rich_text_editor_in_public_views?
        options[:lines] ||= 25
        options[:context] ||= "participant"
        form.editor attribute, options
      else
        options[:rows] ||= 10
        form.text_area attribute, options
      end
    end
  end
end
