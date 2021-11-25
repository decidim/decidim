# frozen_string_literal: true

module Decidim
  class FlagModalCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper

    def flag_user
      render
    end

    def cache_hash
      cache = []
      cache.push(I18n.locale)
      cache.push(model.reported_by?(current_user) ? 1 : 0)
      cache.push(model.class.name.gsub("::", ":"))
      cache.push(model.id)
      cache.push(current_user.try(:id))
      cache.join(Decidim.cache_key_separator)
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
