# frozen_string_literal: true

module Decidim
  module Verifications
    # This cell is to render the authorization metadata in the renew modal
    class AuthorizationMetadataCell < Decidim::ViewModel
      private

      def metadata(data)
        "<li>#{metadata_key(data)} <strong>#{metadata_value(data)}</strong></li>"
      end

      def metadata_key(data)
        "#{t("#{model.name}.fields.#{data.first}", scope: "decidim.authorization_handlers")}:"
      end

      def metadata_value(data)
        data.second
      end
    end
  end
end
