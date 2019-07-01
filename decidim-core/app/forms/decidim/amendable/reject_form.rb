# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to reject emendations
    class RejectForm < Decidim::Amendable::Form
      mimic :amendment

      attribute :id, Integer

      validates :id, presence: true
    end
  end
end
