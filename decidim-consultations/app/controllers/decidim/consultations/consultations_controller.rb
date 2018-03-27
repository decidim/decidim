# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show consultations in a
    # public layout.
    class ConsultationsController < Decidim::ApplicationController
      layout "layouts/decidim/consultation", only: :show

      include NeedsConsultation
      include FilterResource
      include Paginable
      include Orderable

      helper_method :collection, :consultations, :finished_consultations, :active_consultations, :filter

      helper Decidim::FiltersHelper
      helper Decidim::OrdersHelper
      helper Decidim::SanitizeHelper
      helper Decidim::PaginateHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper

      def index
        authorize! :read, Consultation
        redirect_to consultation_path(active_consultations.first) if active_consultations.count == 1
      end

      def show
        authorize! :read, current_consultation
      end

      def finished
        authorize! :read, Consultation
        render layout: "layouts/decidim/consultation_choose"
      end

      private

      def finished_consultations
        @past_cosultations ||= OrganizationConsultations.for(current_organization).finished.published
      end

      def active_consultations
        @active_consultations ||= OrganizationConsultations.for(current_organization).active.published
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
