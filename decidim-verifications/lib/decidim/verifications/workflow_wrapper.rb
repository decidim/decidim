# frozen_string_literal: true

require_relative "base_wrapper"

module Decidim
  module Verifications
    class WorkflowWrapper < BaseWrapper
      alias key name

      def type
        "multistep"
      end

      def root_path(redirect_url: nil)
        main_engine.send(:root_path, redirect_url: redirect_url)
      end

      def resume_authorization_path(redirect_url: nil)
        main_engine.send(:edit_authorization_path, redirect_url: redirect_url)
      end

      def admin_root_path
        public_send(:"decidim_admin_#{name}").send(:root_path)
      end

      private

      def main_engine
        public_send(:"decidim_#{name}")
      end
    end
  end
end
