# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows to send reminders.
      # It is targeted for customizations for reminder things that lives under
      # a participatory process.
      class RemindersController < Decidim::Admin::RemindersController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
