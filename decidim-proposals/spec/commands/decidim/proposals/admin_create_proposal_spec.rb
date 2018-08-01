# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe Decidim::Proposals::Admin::CreateProposal do
        let(:form_klass) { Decidim::Proposals::Admin::ProposalForm }

        it_behaves_like "create a proposal", false
      end
    end
  end
end
