# frozen_string_literal: true

module Decidim
  module Elections
    module Trustees
      # A class used to find trustees by participatory space.
      class ByParticipatorySpace < Decidim::Query
        # Initializes the class.
        #
        def initialize(participatory_space)
          @participatory_space = participatory_space
        end

        # Gets trustees by participatory space.
        def query
          Decidim::Elections::Trustee
            .includes([:user])
            .joins(:trustees_participatory_spaces)
            .merge(Decidim::Elections::TrusteesParticipatorySpace.where(participatory_space: @participatory_space, considered: true))
        end
      end
    end
  end
end
