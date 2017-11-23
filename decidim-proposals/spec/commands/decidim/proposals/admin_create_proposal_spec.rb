# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe CreateProposal do
        let(:form_klass) { ProposalForm }

        it_behaves_like "create a proposal", false
      end
    end
  end
end
