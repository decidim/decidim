# frozen_string_literal: true

module Decidim
  module Elections
    class ResponseOption < Elections::ApplicationRecord
      include Decidim::TranslatableResource

      belongs_to :question

      default_scope { order(arel_table[:id].asc) }

      translatable_fields :body

      validates :body, presence: true

      def presenter
        Decidim::Elections::ResponseOptionPresenter.new(self)
      end
    end
  end
end
