# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Withdraw do
      let!(:component) { create(:proposal_component) }
      let!(:amendable) { create(:proposal, component: component) }
      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation, amender: emendation.creator_author }
      let(:command) { described_class.new(amendment, amendment.amender) }

      include_examples "withdraw amendment"
    end
  end
end
