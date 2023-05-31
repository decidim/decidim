# frozen_string_literal: true

module Decidim
  class FlagModalCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper

    def flag_user
      render
    end

    def cache_hash
      hash = []
      hash.push(I18n.locale)
      hash.push(current_user.try(:id))
      hash.push(model.reported_by?(current_user) ? 1 : 0)
      hash.push(model.class.name.gsub("::", ":"))
      hash.push(model.id)
      hash.join(Decidim.cache_key_separator)
    end

    private

    def frontend_administrable?
      author.respond_to?(:nickname) &&
        model.can_be_administered_by?(current_user) &&
        (model.respond_to?(:official?) && !model.official?)
    end

    def link_to_profile
      author.presenter.profile_url
    end

    def author
      model.try(:creator_identity) || model.try(:normalized_author)
    end

    def user_report_form
      Decidim::ReportForm.from_params(reason: "spam")
    end

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def hide_checkbox_id
      @hide_checkbox_id ||= Digest::MD5.hexdigest("report_form_hide_#{model.class.name}_#{model.id}")
    end

    def report_form
      @report_form ||= begin
        context = { can_hide: model.try(:can_be_administered_by?, current_user) }
        Decidim::ReportForm.new(reason: "spam").with_context(context)
      end
    end
  end
end
