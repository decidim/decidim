# frozen_string_literal: true

module Decidim
  module Verifications
    class RevocationsCell < Decidim::ViewModel
      # This cell renders revocation options - Revoke all or Revoke before date

      def show
        @form = Decidim::Verifications::Admin::RevocationsBeforeDateForm.from_params(params)
        render
      end

      protected

      def decidim_verifications
        Decidim::Verifications::Engine.routes.url_helpers
      end
    end
  end
end
