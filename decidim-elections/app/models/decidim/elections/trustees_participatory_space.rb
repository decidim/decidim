# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a trustee participatory space in the Decidim::Elections component. It has a reference
    # to a trustee (user), a polymorphic reference to participatory spaces and stores the status (considered)
    # for the trustee.
    class TrusteesParticipatorySpace < ApplicationRecord
      belongs_to :trustee, foreign_key: "decidim_elections_trustee_id", class_name: "Decidim::Elections::Trustee", inverse_of: :trustees_participatory_spaces
      belongs_to :participatory_space, foreign_type: "participatory_space_type", polymorphic: true
    end
  end
end
