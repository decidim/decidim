# frozen_string_literal: true

module Decidim
  class FlagModalCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper

    def flag_user
      render
    end

    private

    def user_report_form
      Decidim::ReportForm.from_params(reason: "spam")
    end

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def report_form
      @report_form ||= Decidim::ReportForm.new(reason: "spam")
    end
  end
end
