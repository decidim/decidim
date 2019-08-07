# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Consultations
    module OverrideCategorization
      extend ActiveSupport::Concern

      included do
        # This relationship exists only by compatibility reasons.
        # Consultations are not intended to have categories.
        has_many :categories,
                 foreign_key: "decidim_participatory_space_id",
                 foreign_type: "decidim_participatory_space_type",
                 dependent: :destroy,
                 as: :participatory_space
      end
    end
  end
end
