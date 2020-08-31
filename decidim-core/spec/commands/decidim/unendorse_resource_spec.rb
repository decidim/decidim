# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UnendorseResource do
    describe "User unendorse resource" do
      let(:endorsement) { create(:endorsement) }
      let(:command) { described_class.new(endorsement.resource, endorsement.author) }

      it "broadcasts ok" do
        expect(endorsement).to be_valid
        expect { command.call }.to broadcast :ok
      end

      it "Removes the endorsement" do
        expect(endorsement).to be_valid
        expect do
          command.call
        end.to change(Endorsement, :count).by(-1)
      end

      it "Decreases the endorsements counter by one" do
        resource = endorsement.resource
        expect(Endorsement.count).to eq(1)
        expect do
          command.call
          resource.reload
        end.to change { resource.endorsements_count }.by(-1)
      end
    end

    describe "Organization unendorses resource" do
      let(:endorsement) { create(:user_group_endorsement) }
      let(:command) { described_class.new(endorsement.resource, endorsement.author, endorsement.user_group) }

      it "broadcasts ok" do
        expect(endorsement).to be_valid
        expect { command.call }.to broadcast :ok
      end

      it "Removes the endorsement" do
        expect(endorsement).to be_valid
        expect do
          command.call
        end.to change(Endorsement, :count).by(-1)
      end

      it "Do not decreases the endorsement counter by one" do
        expect(endorsement).to be_valid
        command.call

        resource = endorsement.resource
        resource.reload
        expect(resource.endorsements_count).to be_zero
      end
    end
  end
end
