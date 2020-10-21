# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnsuspendUser do
    subject { described_class.new(suspendable, current_user) }

    let(:current_user) { create :user, :admin }
    let(:suspendable) { create :user, :managed, suspended: true }

    context "when the suspension is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
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
