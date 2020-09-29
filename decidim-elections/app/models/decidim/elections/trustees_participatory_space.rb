# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a trustee in the Decidim::Elections component. It stores a
    # public key and has a reference to Decidim::User.
    class TrusteesParticipatorySpace < ApplicationRecord
      belongs_to :trustee, foreign_key: "decidim_elections_trustee_id", class_name: "Decidim::Elections::Trustee", inverse_of: :trustees_participatory_spaces
      belongs_to :participatory_space, foreign_key: "participatory_space_id", foreign_type: "participatory_space_type", polymorphic: true
    end
  end
end
