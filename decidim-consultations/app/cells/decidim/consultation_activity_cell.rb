# frozen_string_literal: true

module Decidim
  # A cell to display when a Consultation has been published.
  class ConsultationActivityCell < ActivityCell
    def title
      I18n.t "decidim.consultations.last_activity.new_consultation"
    end
  end
end
