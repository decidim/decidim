# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::PublishAssembly do
    subject { described_class.new(my_assembly, user) }

    let(:my_assembly) { create :assembly, :unpublished, organization: user.organization }
    let(:user) { create :user }

    context "when the assembly is nil" do
      let(:my_assembly) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the assembly is published" do
      let(:my_assembly) { create :assembly }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the assembly is not published" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "publishes it" do
        subject.call
        my_assembly.reload
        expect(my_assembly).to be_published
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("publish", my_assembly, user, visibility: "all")
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
