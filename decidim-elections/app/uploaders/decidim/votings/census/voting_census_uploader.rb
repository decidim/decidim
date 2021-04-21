# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # This class deals with saving voting cenusus access codes export Zip Files to App
      class VotingCensusUploader < Decidim::DataPortabilityUploader
        def default_path
          "uploads/voting-census/"
        end
      end
    end
  end
end
