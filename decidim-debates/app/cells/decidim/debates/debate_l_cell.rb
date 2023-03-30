# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Debates
    # This cell renders the List (:l) meeting card
    # for an instance of a Meeting
    class DebateLCell < Decidim::CardLCell
      include Decidim::SanitizeHelper
      delegate :component_settings, to: :controller

      alias debate model

      def has_description?
        true
      end

      def author_presenter
        if model.author.respond_to?(:official?) && model.author.official?
          Decidim::Core::OfficialAuthorPresenter.new
        elsif model.user_group
          model.user_group.presenter
        else
          model.author.presenter
        end
      end

      def title
        presenter.title(html_escape: true)
      end

      def description
        attribute = model.try(:short_description) || model.try(:body) || model.description
        text = translated_attribute(attribute)

        decidim_sanitize(html_truncate(text, length: 240))
      end

      private

      def presenter
        present(model)
      end

      def metadata_cell
        "decidim/debates/debate_card_metadata"
      end
    end
  end
end
