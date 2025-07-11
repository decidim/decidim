# frozen_string_literal: true

module Decidim
  module Elections
    class Vote < Elections::ApplicationRecord
      include Decidim::Traceable
      belongs_to :question, class_name: "Decidim::Elections::Question"
      belongs_to :response_option, class_name: "Decidim::Elections::ResponseOption", counter_cache: true

      attr_readonly :voter_uid, :question_id

      validates :voter_uid, presence: true

      validate :response_belong_to_question

      # To ensure records cannot be deleted
      before_destroy { |_record| raise ActiveRecord::ReadOnlyRecord }

      private

      def response_belong_to_question
        return unless question && response_option
        return if question.response_options.include?(response_option)

        errors.add(:response_option, :invalid)
      end
    end
  end
end
