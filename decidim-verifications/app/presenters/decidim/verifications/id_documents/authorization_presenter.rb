# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      class AuthorizationPresenter < SimpleDelegator
        def rejected?
          verification_metadata["rejected"] == true
        end
      end
    end
  end
end
