# frozen_string_literal: true
require "spec_helper"
require_relative "../../../shared/proposal_form_examples"

module Decidim
  module Proposals
    describe ProposalForm do
      it_behaves_like "a proposal form"

      let(:params) do
        super.merge(
          user_group_id: user_group_id
        )
      end
    end
  end
end
