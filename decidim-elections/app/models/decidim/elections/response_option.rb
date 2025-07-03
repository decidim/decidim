# frozen_string_literal: true

module Decidim
  module Elections
    class ResponseOption < Elections::ApplicationRecord
      include Decidim::TranslatableResource

      belongs_to :question
      has_many :votes, class_name: "Decidim::Elections::Vote", foreign_key: :decidim_elections_response_option_id, dependent: :destroy


      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      validates :body, presence: true

      def translated_body
        Decidim::Forms::ResponseOptionPresenter.new(self).translated_body
      end
    end
  end
end
