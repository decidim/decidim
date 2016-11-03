# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module Admin
    # A module that adds functionalities to the Decidim::User model class.
    module UserExtends
      extend ActiveSupport::Concern

      included do
        has_many :participatory_process_user_roles, foreign_key: "decidim_user_id", class_name: Decidim::ParticipatoryProcessUserRole
        has_many :participatory_processes, through: :participatory_process_user_roles
      end
    end
  end
end
