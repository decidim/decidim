# frozen_string_literal: true

module Decidim
  module Consultations
    # This module, when injected into a controller, ensures there's a
    # consultation available and deducts it from the context.
    module NeedsConsultation
      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :current_consultation
        end
      end

      def self.extended(base)
        base.extend Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      def self.included(base)
        base.include Decidim::NeedsOrganization, InstanceMethods

        enhance_controller(base)
      end

      module InstanceMethods
        # Public: Finds the current Consultation given this controller's
        # context.
        #
        # Returns the current Consultation.
        def current_consultation
          @current_consultation ||= detect_consultation
        end

        alias current_participatory_space current_consultation

        private

        def detect_consultation
          request.env["current_consultation"] ||
            organization_consultations.find_by!(slug: params[:consultation_slug] || params[:slug])
        end

        def organization_consultations
          @organization_consultations ||= OrganizationConsultations.new(current_organization).query
        end
      end
    end
  end
end
