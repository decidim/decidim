# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # This controller allows to send reminders.
      # It is targeted for customizations for reminder things that lives under
      # an assembly.
      class RemindersController < Decidim::Admin::RemindersController
        include Concerns::AssemblyAdmin
      end
    end
  end
end
