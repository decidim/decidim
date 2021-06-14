# frozen_string_literal: true

module Decidim
  module Votings
    module Census
      # This class serializes a Voting::Census::Datum
      class DatumSerializer < Decidim::Exporters::Serializer
        include Decidim::ApplicationHelper

        # Public: Initializes the serializer with a Voting::Census::Datum.
        def initialize(datum)
          @datum = datum
        end

        # Public: Exports a hash with the serialized data for this datum.
        def serialize
          {
            full_name: datum.full_name,
            full_address: datum.full_address,
            postal_code: datum.postal_code,
            access_code: datum.access_code
          }
        end

        attr_reader :datum
      end
    end
  end
end
