# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DummyResources::CreateDummyResource do
    subject { described_class.new(form) }

    let(:current_component) { create(:component) }
    let!(:current_user) { create(:user, organization: current_component.organization) }
    let(:title) { { "en" => "Dummy resource title" } }
    let(:body) { "Dummy resource body" }
    let(:uploaded_images) { [] }
    let(:photos) { [] }
    let(:invalid) { false }
    let(:form) do
      double(
        invalid?: invalid,
        current_user:,
        title:,
        body:,
        photos:,
        add_photos: uploaded_images,
        current_component:
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:resource) { DummyResources::DummyResource.last }

      it "creates the resource" do
        expect { subject.call }.to change(DummyResources::DummyResource, :count).by(1)
      end

      it "sets the title" do
        subject.call
        expect(resource.title).to eq title
      end

      it "sets the body" do
        subject.call
        expect(resource.body).to eq body
      end

      it "sets the author" do
        subject.call
        expect(resource.author).to eq current_user
      end

      it "sets the component" do
        subject.call
        expect(resource.component).to eq current_component
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      context "when uploading images" do
        let(:uploaded_images) do
          [
            { file: upload_test_file(Decidim::Dev.asset("city.jpeg"), content_type: "image/jpeg") },
            { file: upload_test_file(Decidim::Dev.asset("city2.jpeg"), content_type: "image/jpeg") }
          ]
        end

        it "creates a gallery for the resource" do
          expect { subject.call }.to change(Decidim::Attachment, :count).by(2)
          resource = DummyResources::DummyResource.last
          expect(resource.photos.count).to eq(2)
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(resource)
        end

        context "when gallery is left blank" do
          let(:uploaded_images) { [] }

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
