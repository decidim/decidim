# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalForm do
      it_behaves_like "a proposal form", i18n: false, admin: false
    end
  end
end
