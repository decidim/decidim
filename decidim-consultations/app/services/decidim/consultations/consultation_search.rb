# frozen_string_literal: true

module Decidim
  module Consultations
    # Service that encapsulates all logic related to filtering consultations.
    class ConsultationSearch < Searchlight::Search
      # Public: Initializes the service.
      # page        - The page number to paginate the results.
      # per_page    - The number of proposals to return per page.
      def initialize(options = {})
        super(options)
      end

      def base_query
        Decidim::Consultation.where(organization: options[:organization]).published
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where("title->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          .or(
            query.where("description->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          )
          .or(
            query.where("subtitle->>'#{current_locale}' ILIKE ?", "%#{search_text}%")
          )
      end

      # Handle the state filter
      def search_state
        case state
        when "active"
          query.active
        when "upcoming"
          query.upcoming
        when "finished"
          query.finished
        else # Assume all
          query
        end
      end

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
