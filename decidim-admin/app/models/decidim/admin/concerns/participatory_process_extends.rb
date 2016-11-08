# frozen_string_literal: true
require "active_support/concern"

module Decidim
  module Admin
    # A module that adds functionalities to the Decidim::ParticipatoryProcess
    # model class.
    module ParticipatoryProcessExtends
      extend ActiveSupport::Concern

      included do
        has_many :user_roles, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcessUserRole

        def admins
          User.where(
            id: user_roles.where(role: :admin).pluck(:decidim_user_id)
          )
        end
      end
    end
  end
end
