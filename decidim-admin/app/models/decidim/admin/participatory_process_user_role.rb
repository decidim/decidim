# frozen_string_literal: true
module Decidim
  module Admin
    # Defines a relation between a user and a participatory process, and what
    # kind of relation does the user has.
    class ParticipatoryProcessUserRole < ApplicationRecord
      belongs_to :user, foreign_key: "decidim_user_id", class_name: Decidim::User
      belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess

      ROLES = %w(admin).freeze
      validates :role, inclusion: { in: ROLES }
    end
  end
end
