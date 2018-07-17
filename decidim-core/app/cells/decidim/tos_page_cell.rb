# frozen_string_literal: true

module Decidim
  # This cell renders specific _partials_ for the `terms_and_conditions` StaticPage
  # the `model` is the partial to render
  # - :announcement, the TOS updated announcement when redirected to the TOS page.
  # - :sticky_form, the Accept updated TOS form in the TOS page.
  # - :refuse_btn_modal, the Modal with info when refusing the updated TOS.
  class TosPageCell < Decidim::ViewModel
    include Decidim::SanitizeHelper
    include Cell::ViewModel::Partial

    delegate :current_user, to: :controller, prefix: false

    def show
      return if model.nil?
      return unless current_user
      return if current_user.tos_accepted?
      render model
    end

    private

    def announcement_args
      args = {
        callout_class: "warning",
        announcement: {
          title: t("required_review.title", scope: "decidim.pages.terms_and_conditions"),
          body: t("required_review.body", scope: "decidim.pages.terms_and_conditions")
        }
      }
      args
    end
  end
end
