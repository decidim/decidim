# frozen_string_literal: true

module Decidim
  class ReportUserButtonCell < ButtonCell
    include ActionView::Helpers::FormOptionsHelper

    def flag_modal
      return render :already_reported_modal if model.reported_by?(current_user)

      render
    end

    private

    def report_form
      @report_form ||= Decidim::ReportForm.from_params(reason: "spam")
    end

    def report_path
      @report_path ||= decidim.report_user_path(sgid: model.to_sgid.to_s)
    end

    def user_reportable?
      model.is_a?(Decidim::UserReportable)
    end

    def frontend_administrable?
      current_user&.admin?
    end

    def builder
      Decidim::FormBuilder
    end

    def only_button?
      options[:only_button]
    end

    def modal_id
      options[:modal_id] || "flagUserModal"
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
