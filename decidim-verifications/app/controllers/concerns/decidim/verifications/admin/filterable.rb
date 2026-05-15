# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Verifications
    module Admin
      module Filterable
        extend ActiveSupport::Concern

        included do
          include Decidim::Admin::Filterable

          private

          def base_query
            CsvDatum
              .where(organization: current_organization)
              .page(params[:page])
              .per(15)
          end
        end
      end
    end
  end
end
