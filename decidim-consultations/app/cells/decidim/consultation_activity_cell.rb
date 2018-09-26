# frozen_string_literal: true

module Decidim
  class ConsultationActivityCell < ActivityCell
    def title
      I18n.t "decidim.consultations.last_activity.new_consultation"
    end
  end
end
