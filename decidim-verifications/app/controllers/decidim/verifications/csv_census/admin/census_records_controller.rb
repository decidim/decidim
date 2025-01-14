# frozen_string_literal: true

module Decidim
  module Verifications
    module CsvCensus
      module Admin
        class CensusRecordsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          include Decidim::Admin::WorkflowsBreadcrumb

          add_breadcrumb_item_from_menu :workflows_menu

          def index; end

          def new; end

          def create; end
        end
      end
    end
  end
end
