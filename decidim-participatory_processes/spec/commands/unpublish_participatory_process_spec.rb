# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UnpublishParticipatoryProcess do
    subject { described_class.new(my_process, user) }

    let(:my_process) { create :participatory_process, :published, organization: user.organization }
    let(:user) { create :user }

    context "when the process is nil" do
      let(:my_process) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is not published" do
      let(:my_process) { create :participatory_process, :unpublished }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the process is published" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("unpublish", my_process, user)

        subject.call
      end

      it "unpublishes it" do
        subject.call
        my_process.reload
        expect(my_process).not_to be_published
      end
    end
  end
end
