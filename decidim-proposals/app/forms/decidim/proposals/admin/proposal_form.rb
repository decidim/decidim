# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Decidim::Proposals::Admin::ProposalBaseForm
        translatable_attribute :title, String do |field, _locale|
          validates field, length: { in: 15..150 }, if: Proc.new { |resource| resource.send(field).present? }
        end
      end
    end
  end
end
