# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class ElectionStatusForm < Decidim::Form
        attribute :status_action, Symbol

        validates :status_action, presence: true, inclusion: { in: [:start, :end, :publish_results] }
      end
    end
  end
end
