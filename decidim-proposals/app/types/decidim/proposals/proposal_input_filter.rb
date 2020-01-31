# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalInputFilter < Decidim::Core::BaseInputFilter
      include Decidim::Core::HasPublishableInputFilter

      graphql_name "ProposalFilter"
      description "A type used for filtering proposals"
    end
  end
end
