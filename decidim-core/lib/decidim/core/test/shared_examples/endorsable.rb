# frozen_string_literal: true

require "spec_helper"

shared_examples_for "endorsable" do
  context "when endorsable" do
    let(:user) { create(:user, organization: subject.organization) }

    describe "#endorsed_by?" do
      context "with User endorsement" do
        it "returns false if the resource is not endorsed by the given user" do
          expect(subject).not_to be_endorsed_by(user)
        end

        it "returns true if the resource is endorsed by the given user" do
          create(:endorsement, resource: subject, author: user)
          expect(subject).to be_endorsed_by(user)
        end
      end

      context "with Organization endorsement" do
        let!(:user_group) { create(:user_group, verified_at: Time.current, organization: user.organization) }
        let!(:membership) { create(:user_group_membership, user:, user_group:) }

        before { user_group.reload }

        it "returns false if the resource is not endorsed by the given organization" do
          expect(subject).not_to be_endorsed_by(user, user_group)
        end

        context "when there's an endorsement" do
          let!(:endorsement) { create(:endorsement, resource: subject, author: user, user_group:) }

          before { user_group.reload }

          it "returns false if the resource is not endorsed by the given user" do
            expect(subject).not_to be_endorsed_by(user)
          end

          it "returns true if the resource is endorsed by the given organization" do
            expect(subject).to be_endorsed_by(user, user_group)
          end

          context "with another user" do
            let!(:another_user) { create(:user, :confirmed, organization: user.organization) }
            let!(:another_membership) { create(:user_group_membership, user: another_user, user_group:, role: "admin") }

            before { user_group.reload }

            it "returns true if the resource is endorsed by other user of the same organization" do
              expect(subject).to be_endorsed_by(another_user, user_group)
            end
          end

          context "with another organization" do
            let!(:another_user_group) { create(:user_group, verified_at: Time.current, organization: user.organization) }
            let!(:another_membership) { create(:user_group_membership, user:, user_group: another_user_group) }

            before { another_user_group.reload }

            it "returns false if the resource is not endorsed by another organization of the same user" do
              expect(subject).not_to be_endorsed_by(user)
            end
          end
        end
      end
    end
  end
end
