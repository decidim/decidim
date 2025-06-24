# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class ElectionStatusForm < Decidim::Form
        attribute :status_action, Symbol
        attribute :question_id, Integer

        validates :status_action, presence: true, inclusion: { in: [:start, :end, :publish_results, :show_question] }
      end
    end
  end
end
