# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcessType do
    subject { described_class.new(process_type, form) }

    let(:organization) { create(:organization) }
    let(:process_type) { create :participatory_process_type, organization: }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessTypeForm,
        title: { en: "new title" },
        current_user: user,
        current_organization: organization,
        invalid?: invalid
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:invalid) { false }

      it "updates the participatory process type" do
        subject.call
        process_type.reload

        expect(process_type.title["en"]).to eq("new title")
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(process_type, user, hash_including(:title))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
