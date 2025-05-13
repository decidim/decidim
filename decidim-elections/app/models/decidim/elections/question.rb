# frozen_string_literal: true

module Decidim
  module Elections
    class Question < ApplicationRecord
      include Decidim::TranslatableResource
      include Decidim::Orderable

      belongs_to :election, class_name: "Decidim::Elections::Election", inverse_of: :questions

      has_many :answers, class_name: "Decidim::Elections::Answer", inverse_of: :question, dependent: :destroy

      translatable_fields :statement, :description

      validates :statement, presence: true

      acts_as_list scope: :election
    end
  end
end
