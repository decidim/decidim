# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnendorseResource do
    describe "user unendorse resource" do
      let(:endorsement) { create(:endorsement) }
      let(:command) { described_class.new(endorsement.resource, endorsement.author) }

      it "broadcasts ok" do
        expect(endorsement).to be_valid
        expect { command.call }.to broadcast :ok
      end

      it "removes the endorsement" do
        expect(endorsement).to be_valid
        expect do
          command.call
        end.to change(Endorsement, :count).by(-1)
      end

      it "decreases the endorsements counter by one" do
        resource = endorsement.resource
        expect(Endorsement.count).to eq(1)
        expect do
          command.call
          resource.reload
        end.to change { resource.endorsements_count }.by(-1)
      end
    end
  end
end
