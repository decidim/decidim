# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Accountability
    class ResultCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, s_model, options
      end

      private

      def s_model
        OpenStruct.new(
          title: "Title",
          text: "long text",
          title_link_path: "/",
          title_link_text: "Link text",
          content_link_path: "/",
          content_link_text: "Content Link text"
        )
      end

      def card_size
        "decidim/card_s"
      end
    end
  end
end
