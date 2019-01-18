# frozen_string_literal: true

module Decidim
  module Budgets
    #
    # Decorator for projects
    #
    class ProjectPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::TranslationsHelper

      def author
        @author ||= Decidim::UserPresenter.new(super)
      end

      def project_path
        project = __getobj__
        Decidim::ResourceLocatorPresenter.new(project).path
      end

      def display_mention
        link_to translated_attribute(title), project_path
      end
    end
  end
end
