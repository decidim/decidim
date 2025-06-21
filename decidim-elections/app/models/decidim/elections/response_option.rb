# frozen_string_literal: true

module Decidim
  module Elections
    class ResponseOption < Elections::ApplicationRecord
      include Decidim::TranslatableResource

      belongs_to :question

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      validates :body, presence: true

      def translated_body
        Decidim::Forms::ResponseOptionPresenter.new(self).translated_body
      end
    end
  end
end
