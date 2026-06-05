# frozen_string_literal: true

require "spec_helper"

describe Decidim::Pages::Admin::UpdatePage do
  let(:form_klass) { Decidim::Pages::Admin::PageForm }

  let(:component) { create(:page_component) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:attachment_params) { nil }
  let(:uploaded_photos) { [] }

  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  let!(:page) { create(:page, component:) }

  describe "call" do
    let(:form_params) do
      {
        body: { en: "A reasonable proposal body" },
        attachments: attachment_params,
        add_photos: uploaded_photos
      }
    end

    let(:command) do
      described_class.new(form, page)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcast invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "does not update the page" do
        expect do
          command.call
        end.not_to change(page, :body)
      end
    end

    describe "when the form is valid" do
      it "broadcast ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the page" do
        expect do
          command.call
        end.to change(page, :body)
      end

      context "when attachments are allowed" do
        let(:attachment_params) do
          blob = ActiveStorage::Blob.create_and_upload!(
            io: Rack::Test::UploadedFile.new(Decidim::Core::Engine.root.join("db", "seeds", "city.jpeg"), "image/jpeg"),
            filename: "city.jpeg",
            content_type: "image/jpeg"
          )
          {
            title: "My attachment",
            file: blob.signed_id
          }
        end
        let(:uploaded_photos) { [attachment_params] }

        it "creates an attachment for the page" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(1)
          last_page = Decidim::Pages::Page.last
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(last_page)
        end
      end
    end
  end
end
