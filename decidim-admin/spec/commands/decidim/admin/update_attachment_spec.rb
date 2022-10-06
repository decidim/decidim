# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateAttachment do
    let!(:participatory_process) { create(:participatory_process) }
    let!(:attachment) { create(:attachment, attached_to: participatory_process) }
    let!(:user) { create(:user) }

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
        file:,
        attachment_collection: nil,
        weight: 2
      )
    end
    let(:file) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }

    describe "when valid" do
      before do
        allow(form).to receive(:invalid?).and_return(false)
      end

      it "broadcasts :ok and updates the attachment" do
        expect do
          described_class.call(attachment, form, user)
        end.to broadcast(:ok)

        expect(attachment["title"]["en"]).to eq("An image")
        expect(attachment.weight).to eq(2)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:update, attachment, user, {})
          .and_call_original

        expect { described_class.call(attachment, form, user) }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("update")
        expect(action_log.version).to be_present
      end
    end

    describe "when invalid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "does not update the component" do
        expect do
          described_class.call(attachment, form, user)
        end.to broadcast(:invalid)

        attachment.reload
        expect(attachment.title["en"]).not_to eq("An image")
      end
    end
  end
end
