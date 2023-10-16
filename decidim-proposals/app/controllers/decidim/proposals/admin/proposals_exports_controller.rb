# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalsExportsController < Decidim::Admin::ExportsController
        include Decidim::Proposals::Admin::Filterable

        def create
          collection = filtered_collection
          raise collection.inspect

          super(collection)
        end
      end
    end
  end
end
