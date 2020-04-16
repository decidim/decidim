# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      class Permissions < Decidim::DefaultPermissions
        def permissions
          permission_action
        end
      end
    end
  end
end
