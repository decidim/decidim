# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Withdraw do
      let!(:component) { create(:proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:proposal, component:) }
      let!(:emendation) { create(:proposal, component:) }
      let!(:amendment) { create(:amendment, amendable:, emendation:, amender: emendation.creator_author) }

      let(:command) { described_class.new(amendment, current_user) }
      let(:current_user) { amendment.amender }

      include_examples "withdraw amendment" do
        it "changes the emendation state" do
          expect(emendation).not_to be_withdrawn
          expect { command.call }.to change { emendation.reload.withdrawn? }.from(false).to(true)
          expect(emendation.withdrawn_at).to be_present
        end
      end
    end
  end
end
