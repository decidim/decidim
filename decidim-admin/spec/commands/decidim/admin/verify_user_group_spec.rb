# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe VerifyUserGroup do
    subject { described_class.new(user_group, current_user, via_csv: via_csv) }

    let(:via_csv) { false }
    let(:current_user) { create :user, organization: organization }
    let(:organization) { create :organization }

    describe "User group validation is pending" do
      let!(:user_group) { create(:user_group, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcasts invalid in return" do
          allow(user_group).to receive(:valid?).and_return(false)
          expect { subject.call }.to broadcast(:invalid)

          expect(user_group.rejected_at).to be_nil
          expect(user_group.verified_at).to be_nil
        end
      end

      context "when the command is valid" do
        it "rejects the user group" do
          expect { subject.call }.to broadcast(:ok)

          expect(user_group.rejected_at).to be_nil
          expect(user_group.verified_at).not_to be_nil
        end

        it "tracks the changes" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("verify", user_group, current_user)

          subject.call
        end
      end
    end

    describe "User group is already rejected" do
      let!(:user_group) { create(:user_group, rejected_at: Time.current, users: [create(:user, organization: organization)]) }

      context "when the command is not valid" do
        let(:invalid) { true }

        it "broadcasts invalid in return and do not clean rejected_at" do
          allow(user_group).to receive(:valid?).and_return(false)
          expect { subject.call }.to broadcast(:invalid)

          expect(user_group.rejected_at).not_to be_nil
          expect(user_group.verified_at).to be_nil
        end
      end

      context "when the command is valid" do
        it "verifies the user group" do
          expect { subject.call }.to broadcast(:ok)

          expect(user_group.rejected_at).to be_nil
          expect(user_group.verified_at).not_to be_nil
        end

        it "tracks the changes" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("verify", user_group, current_user)

          subject.call
        end

        context "when the verification is performed via csv" do
          let(:via_csv) { true }

          it "uses another action to track the changes" do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("verify_via_csv", user_group, current_user)

            subject.call
          end
        end
      end
    end
  end
end
