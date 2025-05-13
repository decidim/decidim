module Decidim
  module Elections
    class Answer < ApplicationRecord
      include Decidim::TranslatableResource
      include Decidim::Orderable

      belongs_to :question, class_name: "Decidim::Elections::Question", inverse_of: :answers

      translatable_fields :statement

      validates :statement, presence: true

      acts_as_list scope: :question
    end
  end
end
