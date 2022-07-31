# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing newsletters.
    class NewsletterTemplatesController < Decidim::Admin::ApplicationController
      helper_method :templates, :template_manifest

      layout "decidim/admin/newsletters"

      def index
        enforce_permission_to :index, :newsletter
      end

      def show; end

      def preview
        email = NewsletterMailer.newsletter(current_user, fake_newsletter, preview: true)
        Premailer::Rails::Hook.perform(email)
        render html: email.html_part.body.decoded.html_safe
      end

      private

      def templates
        @templates ||= Decidim.content_blocks.for(:newsletter_template)
      end

      def template_manifest
        @template_manifest ||= Decidim
                               .content_blocks
                               .for(:newsletter_template)
                               .find { |manifest| manifest.name.to_s == params[:id] }
      end

      def fake_newsletter
        @fake_newsletter ||= Decidim::Admin::FakeNewsletter.new(current_organization, template_manifest)
      end
    end
  end
end
