# frozen_string_literal: true

module Decidim
  class FlagModalCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper

    private

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def report_form
      @report_form ||= Decidim::ReportForm.new(reason: "spam")
    end
  end
end
