# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      #
      # Decorator for id document authorizations
      #
      class AuthorizationPresenter < SimpleDelegator
        #
        # Whether the verification has been rejected or not and thus, whether
        # the user should be prompted again to reupload documents
        #
        def rejected?
          verification_metadata["rejected"] == true
        end
      end
    end
  end
end
