# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module ParticipatoryProcesses
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            collection
          end

          def extra_filters
            [:decidim_participatory_process_group_id_eq]
          end
        end
      end
    end
  end
end
