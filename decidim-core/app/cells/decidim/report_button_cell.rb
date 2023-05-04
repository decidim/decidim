# frozen_string_literal: true

module Decidim
  class ReportButtonCell < RedesignedButtonCell
    include ActionView::Helpers::FormOptionsHelper

    private

    def cache_hash
      hash = []
      hash.push(I18n.locale)
      hash.push(current_user.try(:id))
      hash.push(model.reported_by?(current_user) ? 1 : 0)
      hash.push(model.class.name.gsub("::", ":"))
      hash.push(model.id)
      hash.join(Decidim.cache_key_separator)
    end

    def user_report_form
      Decidim::ReportForm.from_params(reason: "spam")
    end

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def report_form
      @report_form ||= Decidim::ReportForm.new(reason: "spam")
    end

    def builder
      Decidim::FormBuilder
    end

    def button_classes
      "button button__sm button__text-secondary"
    end

    def text
      t("decidim.shared.flag_modal.report")
    end

    def icon_name
      "flag-line"
    end

    def html_options
      { data: { "dialog-open": current_user ? "flagModal" : "loginModal" } }
    end
  end
end
