# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comments section for a commentable object.
    class CommentsCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :user_signed_in?, to: :controller

      property :comments

      private

      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      def node_id
        "comments-for-#{commentable_type.demodulize}-#{model.id}"
      end

      def commentable_type
        model.commentable_type
      end

      def comments_data
        {
          commentableType: commentable_type,
          commentableId: model.id,
          locale: I18n.locale,
          toggleTranslations: machine_translations_toggled?
        }
      end

      def machine_translations_toggled?
        options[:machine_translations] == true
      end
    end
  end
end
