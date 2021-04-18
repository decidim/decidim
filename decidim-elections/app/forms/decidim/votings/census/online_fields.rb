# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Votings
    module Census
      # Definition of the fields required to be used on Datum forms for online voting
      module OnlineFields
        extend ActiveSupport::Concern

        included do
          include Decidim::Votings::Census::CheckFields
          include Decidim::Votings::Census::FrontendFields

          attribute :access_code, String
          validates :access_code, presence: true
        end

        # hash of hashed_check_data and access code
        # used by a voter to identify before online voting
        def hashed_online_data
          hash_for hashed_check_data, access_code
        end
      end
    end
  end
end
