# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnsuspendUser do
    subject { described_class.new(suspendable, current_user) }

    let(:current_user) { create :user, :admin }
    let(:suspendable) { create :user, :managed, suspended: true, name: "Testingname" }

    context "when the suspension is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "user is updated" do
        subject.call
        expect(suspendable.suspended).to be(false)
        expect(suspendable.name).to eq("Testingname")
        expect(suspendable.suspended_at).to be_nil
        expect(suspendable.suspension_id).to be_nil
      end

      it "tracks the changes" do
        expect(Decidim.traceability).to receive(:perform_action!)
          .with(
            "unsuspend",
            suspendable,
            current_user,
            extra: {
              reportable_type: suspendable.class.name
            }
          )
        subject.call
      end
    end

    context "when the suspension is not valid" do
      it "broadcasts invalid" do
        allow(suspendable).to receive(:suspended?).and_return(false)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
