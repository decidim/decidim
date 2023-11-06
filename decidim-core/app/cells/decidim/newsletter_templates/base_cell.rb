# frozen_string_literal: true

require "cell/partial"

module Decidim
  module NewsletterTemplates
    class BaseCell < Decidim::ViewModel
      include Decidim::SanitizeHelper
      include Cell::ViewModel::Partial
      include Decidim::NewslettersHelper

      def show
        render :show
      end

      def organization
        options[:organization]
      end
      alias current_organization organization

      def newsletter
        options[:newsletter]
      end

      def recipient_user
        options[:recipient_user]
      end

      def custom_url_for_mail_root
        options[:custom_url_for_mail_root]
      end

      def decidim
        @decidim ||= EngineRouter.new("decidim", {})
      end
    end
  end
end
