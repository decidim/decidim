# frozen_string_literal: true

module Decidim
  module System
    class SystemChecksCell < Decidim::ViewModel
      def show
        render
      end

      private

      def correct_secret_key_base?
        Rails.application.secrets.secret_key_base.length == 128
      end

      def generated_secret_key
        SecureRandom.hex(64)
      end
    end
  end
end
