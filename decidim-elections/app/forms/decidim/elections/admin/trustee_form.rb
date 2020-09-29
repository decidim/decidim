# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to add and edit users as trustees from Decidim's admin panel.
      class TrusteeForm < Decidim::Form
        attribute :user_id, Integer
        attribute :considered, Boolean, default: true
        attribute :full_name, String

        def map_model(model)
          self.user_id = model.decidim_user_id
        end

        def user
          @user ||= current_organization.users.find_by(id: user_id)
        end
      end
    end
  end
end
