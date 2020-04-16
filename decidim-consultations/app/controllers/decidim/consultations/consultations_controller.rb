# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show consultations in a
    # public layout.
    class ConsultationsController < Decidim::Consultations::ApplicationController
      layout "layouts/decidim/consultation", only: :show

      include NeedsConsultation
      include FilterResource
      include Paginable
      include Decidim::Consultations::Orderable

      helper_method :collection, :consultations, :finished_consultations, :active_consultations, :filter

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PaginateHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper
      helper Decidim::ResourceHelper

      def index
        enforce_permission_to :read, :consultation_list
      end

      def show
        enforce_permission_to :read, :consultation, consultation: current_consultation
      end

      private

      def current_participatory_space_manifest
        @current_participatory_space_manifest ||= Decidim.find_participatory_space_manifest(:consultations)
      end

      def consultations
        @consultations = search.results
        @consultations = reorder(@consultations)
        @consultations = paginate(@consultations)
      end

      alias collection consultations

      def search_klass
        ConsultationSearch
      end

      def default_filter_params
        {
          search_text: "",
          state: "all"
        }
      end

      def context_params
        {
          organization: current_organization,
          current_user: current_user
        }
      end
    end
  end
end
