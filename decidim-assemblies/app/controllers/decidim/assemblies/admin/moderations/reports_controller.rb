# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      module Moderations
        # This controller allows admins to manage moderation reports in an assembly.
        class ReportsController < Decidim::Admin::Moderations::ReportsController
          include Concerns::AssemblyAdmin
        end
      end
    end
  end
end
