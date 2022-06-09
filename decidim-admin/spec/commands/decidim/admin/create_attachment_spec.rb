# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateAttachment do
    subject { described_class.call(form, attached_to, user) }
    let(:user) { create(:user) }
    let(:form) do
      instance_double(
        AttachmentForm,
        title: {
          en: "An image",
          ca: "Una imatge",
          es: "Una imagen"
        },
        description: {
          en: "A city",
          ca: "Una ciutat",
          es: "Una ciudad"
        },
        file: file,
        attachment_collection: nil,
        weight: 0
      )
    end
    let(:file) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
    let(:attached_to) { create(:participatory_process) }

    describe "when valid" do
      before do
        allow(form).to receive(:invalid?).and_return(false)
      end

      it "broadcasts :ok and creates the component" do
        expect do
          subject
        end.to broadcast(:ok)

        expect(Decidim::Attachment.count).to eq(1)
      end

      it "notifies the followers" do
        follower = create(:user, organization: attached_to.organization)
        create(:follow, followable: attached_to, user: follower)

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.attachments.attachment_created",
            event_class: Decidim::AttachmentCreatedEvent,
            resource: kind_of(Decidim::Attachment),
            followers: [follower]
          )

        subject
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Attachment, user)
          .and_call_original

        expect { subject }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end

    describe "when invalid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect do
          subject
        end.to broadcast(:invalid)

        expect(Decidim::Attachment.count).to eq(0)
      end
    end
  end
end
