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

    describe "user group unendorses resource" do
      let(:endorsement) { create(:user_group_endorsement) }
      let(:command) { described_class.new(endorsement.resource, endorsement.author, endorsement.user_group) }

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

      it "do not decreases the endorsement counter by one" do
        expect(endorsement).to be_valid
        command.call

        resource = endorsement.resource
        resource.reload
        expect(resource.endorsements_count).to be_zero
      end

      context "when it's from other user" do
        let(:other_user) { create(:user, organization: endorsement.resource.organization) }
        let(:command) { described_class.new(endorsement.resource, other_user, endorsement.user_group) }

        before do
          create :user_group_membership, user: other_user, user_group: endorsement.user_group, role: "admin"
        end

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

        it "do not decreases the endorsement counter by one" do
          expect(endorsement).to be_valid
          command.call

          resource = endorsement.resource
          resource.reload
          expect(resource.endorsements_count).to be_zero
        end
      end
    end
  end
end
