# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalForm do
        it_behaves_like "a proposal form"
        it_behaves_like "a proposal form with meeting as author"
      end
    end
  end
end
