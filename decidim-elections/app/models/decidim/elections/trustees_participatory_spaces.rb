# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a trustee in the Decidim::Elections component. It stores a
    # public key and has a reference to Decidim::User.
    class TrusteesParticipatorySpaces < ApplicationRecord
      belongs_to :trustee, foreign_key: "decidim_elections_trustee_id", class_name: "Decidim::Elections::Trustee"
      belongs_to :participatory_space, polymorphic: true
    end
  end
end
