# frozen_string_literal: true

module Decidim
  module Design
    module Components
      class CardsController < Decidim::Design::ApplicationController
        include Decidim::ControllerHelpers
        include FilterResource
        include Paginable
        helper Decidim::FiltersHelper
        helper Decidim::CardHelper

        helper_method :term

        def index
          Search.call("", current_organization, filters, page_params) do
            on(:ok) do |results|
              expose(sections: results.transform_values { |v| v[:results].first(4) })
            end
          end
        end

        private

        def default_filter_params
          {
            term: params[:term],
            with_resource_type: nil,
            with_space_state: nil,
            decidim_scope_id_eq: nil
          }
        end

        def term
          @term ||= filter_params[:term]
        end

        def filters
          filter_params
        end

        def page_params
          {
            per_page:,
            page: params[:page]
          }
        end
      end
    end
  end
end
