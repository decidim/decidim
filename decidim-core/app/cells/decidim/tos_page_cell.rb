# frozen_string_literal: true

module Decidim
  # This cell renders specific _partials_ for the `terms_of_service` StaticPage
  # the `model` is the partial to render
  # - :announcement, the TOS updated announcement when redirected to the TOS page.
  # - :sticky_form, the Accept updated TOS form in the TOS page.
  # - :refuse_btn_modal, the Modal with info when refusing the updated TOS.
  class TosPageCell < Decidim::ViewModel
    include Cell::ViewModel::Partial

    def show
      return if model.nil?
      return unless current_user
      return if current_user.tos_accepted?

      render model
    end

    private

    def announcement
      {
        title: t("required_review.title", scope: "decidim.pages.terms_of_service"),
        body: t("required_review.body", scope: "decidim.pages.terms_of_service")
      }
    end

    def announcement_options
      {
        callout_class: "warning"
      }
    end
  end
end
