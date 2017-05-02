# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalExportsController < Admin::ApplicationController
        def create
          # call the new proposal export command
          authorize! :read, Proposal
          authorize! :create, ProposalExport
        end
      end
    end
  end
end
