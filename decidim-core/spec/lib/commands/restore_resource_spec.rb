# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::RestoreResource do
    subject { described_class.new(resource, user) }

    let(:resource) { create(:dummy_resource) }
    let(:organization) { resource.component.organization }
    let(:user) { create(:user, organization:) }

    before do
      resource.destroy!
    end

    context "when everything is ok" do
      it "restores the resource" do
        subject.call

        expect(resource.reload).not_to be_deleted
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("restore", resource, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.action).to eq("restore")
      end
    end

    context "when the resource is invalid" do
      before do
        allow(subject).to receive(:invalid?).and_return(true)
      end

      it "does not restore the resource and broadcasts :invalid" do
        expect(resource).not_to receive(:restore!)
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when an associated record was deleted independently before the trash" do
      let(:like) { create(:like, resource:) }

      before do
        like.destroy!
        travel 5.minutes
        resource.destroy! # cascada de trash
      end

      it "does not resurrect the independently-deleted like" do
        subject.call
        expect(like.reload).to be_deleted
      end
    end

    context "when an associated record was deleted as part of the trash cascade" do
      let!(:like) { create(:like, resource:) }

      before { resource.destroy! } # cascade soft-deletes the like at (almost) the same time

      it "restores the cascaded like" do
        subject.call
        expect(like.reload).not_to be_deleted
      end
    end
  end
end
