# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on forms.
  class PublicParticipationCell < Decidim::ViewModel
    private

    def checkbox_text
      I18n.t("public_participation", scope: "decidim.shared.public_participation")
    end
  end
end
