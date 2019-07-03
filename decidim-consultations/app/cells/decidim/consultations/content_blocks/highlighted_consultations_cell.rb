# frozen_string_literal: true

module Decidim
  module Consultations
    module ContentBlocks
      class HighlightedConsultationsCell < Decidim::ViewModel
        delegate :current_user, to: :controller

        def show
          render if highlighted_consultations.any?
        end

        def max_results
          model.settings.max_results
        end

        def highlighted_consultations
          @highlighted_consultations ||= OrganizationActiveConsultations
                                         .new(current_organization)
                                         .query
                                         .limit(max_results)
        end

        def i18n_scope
          "decidim.consultations.pages.home.highlighted_consultations"
        end

        def decidim_consultations
          Decidim::Consultations::Engine.routes.url_helpers
        end

        def voting_ends_text_for(consultation)
          remaining_days = (consultation.end_voting_date - Time.zone.today).to_i
          return I18n.t("voting_ends_today", scope: i18n_scope) if remaining_days.zero?

          I18n.t("voting_ends_in", scope: i18n_scope, count: remaining_days)
        end
      end
    end
  end
end
