# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::PublishParticipatoryProcess do
    subject { described_class.new(my_process, user) }

    let(:my_process) { create :participatory_process, :unpublished, organization: user.organization }
    let(:user) { create :user }

    context "when the process is nil" do
      let(:my_process) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is published" do
      let(:my_process) { create :participatory_process }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is not published" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:update_with_action!)
          .with("publish", my_process, user)

        subject.call
      end

      it "publishes it" do
        subject.call
        my_process.reload
        expect(my_process).to be_published
      end
    end
  end
end
