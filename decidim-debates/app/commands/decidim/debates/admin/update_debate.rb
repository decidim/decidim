# frozen_string_literal: true

module Decidim
  module Debates
    module Admin
      # This command is executed when the user changes a Debate from the admin
      # panel.
      class UpdateDebate < Decidim::Commands::UpdateResource
        fetch_form_attributes :taxonomizations, :information_updates, :instructions, :start_time, :end_time, :comments_enabled

        private

        def attributes
          parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
          parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite

          attrs = {
            title: parsed_title,
            description: parsed_description
          }

          attrs[:comments_layout] = form.comments_layout if resource.comments_count.zero?

          super.merge(attrs)
        end
      end
    end
  end
end
