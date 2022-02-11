# frozen_string_literal: true

module Decidim
  module Elections
    module Trustees
      # A class used to find trustees by participatory space trustee ids.
      class ByParticipatorySpaceTrusteeIds < Decidim::Query
        # Initializes the class.
        #
        def initialize(trustee_ids)
          @trustee_ids = trustee_ids
        end

        # Gets trustees by participatory space trustee ids.
        def query
          Decidim::Elections::Trustee
            .includes([:user])
            .joins(:trustees_participatory_spaces)
            .merge(Decidim::Elections::TrusteesParticipatorySpace.where(decidim_elections_trustee_id: @trustee_ids, considered: true))
        end
      end
    end
  end
end
