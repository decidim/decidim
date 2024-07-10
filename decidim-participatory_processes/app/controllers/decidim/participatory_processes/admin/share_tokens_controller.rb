# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This controller allows sharing unpublished things.
      # It is targeted for customizations for sharing unpublished things that lives under
      # an process.
      class ShareTokensController < Decidim::Admin::ShareTokensController
        include Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
