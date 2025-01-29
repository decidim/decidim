# frozen_string_literal: true

module Decidim
  class ShareWidgetCell < Decidim::ViewModel
    include Decidim::ShortLinkHelper
    include Decidim::SocialShareButtonHelper

    def show
      render if model.present?
    end

    private

    def resource_name
      return "budget_project" if model.is_a?(Decidim::Budgets::Project)

      model.class.name.demodulize.underscore
    end
  end
end
