# frozen_string_literal: true

module Decidim
  module Elections
    class Answer < ApplicationRecord
      include Decidim::TranslatableResource

      belongs_to :question, class_name: "Decidim::Elections::Question", inverse_of: :answers

      translatable_fields :body

      validates :body, presence: true
    end
  end
end
