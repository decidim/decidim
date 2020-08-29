# frozen_string_literal: true

module Decidim
  module Debates
    # Custom helpers, scoped to the debates engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include Decidim::RichTextEditorHelper
      include Decidim::EndorsableHelper
      include Decidim::FollowableHelper

      # If the debate is official or the rich text editor is enabled on the
      # frontend, the debate description is considered as safe content.
      def safe_content?
        debate&.official? || rich_text_editor_in_public_views?
      end

      # If the content is safe, HTML tags are sanitized, otherwise, they are stripped.
      def render_debate_description(debate)
        description = present(debate).description(strip_tags: !safe_content?)

        safe_content? ? decidim_sanitize(description) : simple_format(description)
      end

      # Returns :text_area or :editor based on current_component settings.
      def text_editor_for_debate_description(form)
        text_editor_for(form, :description)
      end
    end
  end
end
