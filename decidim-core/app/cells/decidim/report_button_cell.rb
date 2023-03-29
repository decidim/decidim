# frozen_string_literal: true

module Decidim
  class ReportButtonCell < RedesignedButtonCell
    include ActionView::Helpers::FormOptionsHelper

    def flag_modal
      return render :already_reported_modal if model.reported_by?(current_user)

      render
    end

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

    def only_button?
      options[:only_button]
    end

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def user_reportable?
      model.is_a?(Decidim::UserReportable)
    end

    def report_form
      @report_form ||= user_reportable? ? Decidim::ReportForm.from_params(reason: "spam") : Decidim::ReportForm.new(reason: "spam")
    end

    def report_path
      @report_path ||= user_reportable? ? decidim.report_user_path(sgid: model.to_sgid.to_s) : decidim.report_path(sgid: model.to_sgid.to_s)
    end

    def builder
      Decidim::FormBuilder
    end

    def button_classes
      options[:button_classes] || "button button__sm button__text button__text-secondary"
    end

    def text
      t("decidim.shared.flag_modal.report")
    end

    def icon_name
      "flag-line"
    end

    def html_options
      { data: { "dialog-open": current_user ? modal_id : "loginModal" } }
    end
  end
end
