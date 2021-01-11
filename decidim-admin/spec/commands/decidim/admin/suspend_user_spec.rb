# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe SuspendUser do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: organization }
    let(:suspendable) { create :user, :managed, organization: organization }
    let(:justification) { "justification for suspending the user" }
    let(:user_suspension) { create :justification, :user, :current_user }

    context "when the form is valid" do
      let(:form) do
        double(
          user: suspendable,
          current_user: current_user,
          justification: :justification,
          valid?: true
        )
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok, suspendable)
      end

      it "tracks the changes" do
        expect(Decidim.traceability).to receive(:perform_action!).with("suspend",
                                                                       suspendable,
                                                                       current_user,
                                                                       extra: {
                                                                         reportable_type: form.user.class.name,
                                                                         current_justification: form.justification
                                                                       })
        subject.call
      end
    end

    context "when the form is not ok" do
      let(:form) do
        double(
          valid?: false
        )
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
