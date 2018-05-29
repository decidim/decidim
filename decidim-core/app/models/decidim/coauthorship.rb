# frozen_string_literal: true

module Decidim
  class Coauthorship < ApplicationRecord
    include Decidim::Authorable

    belongs_to :coauthorable, polymorphic: true

    validates :coauthorable, presence: true

    def identity
      user_group || author
    end

    private

    # As it is used to validate by comparing to author.organization
    # @returns The Organization for the Coauthorable
    def organization
      coauthorable&.organization
    end
  end
end
