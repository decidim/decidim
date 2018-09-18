# frozen_string_literal: true

module Decidim
  # This cell is used a based for all S-sized cards. It holds the basic layout
  # so other cells only have to customize a few methods or overwrite views.
  class CardSCell < Decidim::ViewModel
    include Cell::ViewModel::Partial

    def show
      render
    end

    private

    def card_title
      model.title
    end

    def card_content
      model.text
    end

    def card_title_link_path
      model.title_link_path
    end

    def card_title_link_text
      model.title_link_text
    end

    def card_content_link_path
      model.content_link_path
    end

    def card_content_link_text
      model.content_link_text
    end

    def render_title_link?
      card_title_link_path.present? && card_title_link_text.present?
    end

    def render_content_link?
      card_content_link_path.present? && card_content_link_text.present?
    end

    def render_content?
      card_content.present?
    end
  end
end
