# frozen_string_literal: true

module Decidim
  module Verifications
    # This cell renders revocation options - Revoke all or Revoke before date
    class RevocationsCell < Decidim::ViewModel
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
