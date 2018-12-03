# frozen_string_literal: true

module Decidim
  module Amendable
    # A form object used to reject emendations
    class RejectForm < Decidim::Amendable::Form
      mimic :reject_amend

      attribute :id, String

      validates :id, presence: true
    end
  end
end
