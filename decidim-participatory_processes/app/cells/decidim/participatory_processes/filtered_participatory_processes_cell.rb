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
    #   default_filter: "active"
    # )
    class FilteredParticipatoryProcessesCell < Decidim::ViewModel
      include Decidim::FilterResource
      include Decidim::CardHelper

      def elements
        @elements ||= search.result
      end

      private

      def search_collection
        base_relation.published.visible_for(current_user).includes(:area)
      end

      def base_relation
        model
      end

      def default_filter_params
        {
          with_date: default_date_filter,
          with_type: nil
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
