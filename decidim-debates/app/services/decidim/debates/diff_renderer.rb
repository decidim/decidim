# frozen_string_literal: true

module Decidim
  module Debates
    class DiffRenderer < BaseDiffRenderer
      private

      # Lists which attributes will be diffable and how they should be rendered.
      def attribute_types
        {
          title: :i18n,
          description: :i18n,
          information_updates: :i18n,
          instructions: :i18n,
          start_time: :string,
          end_time: :string,
          conclusions: :i18n,
          closed_at: :string
        }
      end

      def debate
        @debate ||= Debate.find_by(id: version.item_id)
      end
    end
  end
end
