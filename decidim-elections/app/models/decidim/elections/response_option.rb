# frozen_string_literal: true

module Decidim
  module Elections
    class ResponseOption < Elections::ApplicationRecord
      include Decidim::TranslatableResource

      belongs_to :question, class_name: "Decidim::Elections::Question", inverse_of: :response_options, counter_cache: true
      has_many :votes, class_name: "Decidim::Elections::Vote", dependent: :restrict_with_error, inverse_of: :response_option

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
