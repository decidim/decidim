# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnblockUser do
    subject { described_class.new(user_to_unblock, current_user) }

    let(:current_user) { create :user, :admin }
    let(:user_to_unblock) { create :user, :managed, blocked: true, name: "Testingname" }

    context "when the blocking is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "user is updated" do
        subject.call
        expect(user_to_unblock.blocked).to be(false)
        expect(user_to_unblock.name).to eq("Testingname")
        expect(user_to_unblock.blocked_at).to be_nil
        expect(user_to_unblock.block_id).to be_nil
      end

      it "tracks the changes" do
        expect(Decidim.traceability).to receive(:perform_action!)
          .with(
            "unblock",
            user_to_unblock,
            current_user,
            extra: {
              reportable_type: user_to_unblock.class.name
            }
          )
        subject.call
      end
    end

    context "when the suspension is not valid" do
      it "broadcasts invalid" do
        allow(user_to_unblock).to receive(:blocked?).and_return(false)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
