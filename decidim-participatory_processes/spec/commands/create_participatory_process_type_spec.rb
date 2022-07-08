# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcessType do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessTypeForm,
        title: { en: "title" },
        current_user: user,
        current_organization: organization,
        invalid?: invalid
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates a participatory process type" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessType, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Decidim::ParticipatoryProcessType, user, hash_including(:title, :organization))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
