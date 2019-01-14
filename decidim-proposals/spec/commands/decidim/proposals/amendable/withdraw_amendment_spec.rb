# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Withdraw do
      let!(:proposal) { create(:proposal) }
      let!(:emendation) { create(:proposal) }
      let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }
      let(:current_user) { emendation.creator_author }
      let(:command) { described_class.new(emendation, current_user) }

      include_examples "withdraw amendment"
    end
  end
end
