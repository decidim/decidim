# frozen_string_literal: true
require "spec_helper"
require_relative "../../../shared/proposal_form_examples"

module Decidim
  module Proposals
    module Admin
      describe ProposalForm do
        it_behaves_like "a proposal form"
      end
    end
  end
end
