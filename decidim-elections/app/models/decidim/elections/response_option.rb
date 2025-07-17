# frozen_string_literal: true

module Decidim
  module Elections
    class ResponseOption < Elections::ApplicationRecord
      include Decidim::TranslatableResource


      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      validates :body, presence: true

      def presenter
        Decidim::Elections::ResponseOptionPresenter.new(self)
      end

      def votes_percent
        @votes_percent ||= question.total_votes.positive? ? (votes_count.to_f / question.total_votes * 100) : 0
      end
    end
  end
end
