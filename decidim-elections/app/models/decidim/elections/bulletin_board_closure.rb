# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election Closure.
    class BulletinBoardClosure < ApplicationRecord
      belongs_to :election,
                 foreign_key: "decidim_elections_election_id",
                 class_name: "Decidim::Elections::Election",
                 inverse_of: :bb_closure

      has_many :results,
               foreign_type: "closurable_type",
               class_name: "Decidim::Elections::Result",
               dependent: :destroy,
               as: :closurable
    end
  end
end
