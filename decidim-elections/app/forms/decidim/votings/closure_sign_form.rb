# frozen_string_literal: true

module Decidim
  module Votings
    class ClosureSignForm < Decidim::Form
      attribute :signed, Boolean

      validates :signed, presence: true
    end
  end
end
