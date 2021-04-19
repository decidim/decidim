# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders a set of filtered participatory processes from a base
    # relation provided by the model
    #
    # The `model` must be a relation of participatory processes
    #
    # Available options:
    #
    # - `default_date_filter` => The date filter to use if not given by
    #    params. If not provided is inferred from the model relation
    #
    # Example:
    #
    # cell(
    #   "decidim/participatory_processes/filtered_participatory_processes",
    #   group.participatory_processes.published,
    #   date_filter: "active"
    # )
    class FilteredParticipatoryProcessesCell < Decidim::ViewModel
      include Decidim::FilterResource
      include Decidim::CardHelper

      def elements
        @elements ||= search.results
      end

      private

      def search_klass
        Decidim::ParticipatoryProcesses::ParticipatoryProcessSearch
      end

      def default_search_params
        {
          base_relation: model,
          date: default_date_filter
        }
      end

      def default_date_filter
        @default_date_filter ||= options[:default_filter].presence || if model.any?(&:active?)
                                                                        "active"
                                                                      elsif model.any?(&:upcoming?)
                                                                        "upcoming"
                                                                      elsif model.any?(&:past?)
                                                                        "past"
                                                                      else
                                                                        "all"
                                                                      end
      end
    end
  end
end
