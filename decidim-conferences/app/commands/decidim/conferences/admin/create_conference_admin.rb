# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command with all the business logic when creating a new conference
      # admin in the system.
      class CreateConferenceAdmin < Decidim::Admin::ParticipatorySpace::CreateAdmin
        private

        attr_reader :form, :participatory_space, :current_user, :user

        def role_params = super.merge(conference: participatory_space)
      end
    end
  end
end
