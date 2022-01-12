# frozen_string_literal: true

shared_examples "admin creates resource gallery" do
  context "when uploading images" do
    let(:uploaded_photos) do
      [
        {
          title: "Picture of the city",
          file: ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg").signed_id
        },
        {
          title: "Picture of another city",
          file: ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city2.jpeg", "image/jpeg"), filename: "city2.jpeg").signed_id
        }
      ]
    end
    let(:photos) { [] }

    it "creates a gallery for the resource" do
      expect { command.call }.to change(Decidim::Attachment, :count).by(uploaded_photos.count)

      resource = resource_class.last
      expect(resource.photos.count).to eq(2)
      last_attachment = Decidim::Attachment.last
      expect(last_attachment.attached_to).to eq(resource)
    end

    context "when gallery is left blank" do
      let(:uploaded_photos) { [] }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end
    end
  end
end

shared_examples "admin manages resource gallery" do
  context "when managing images" do
    let(:uploaded_photos) do
      [
        {
          title: "Picture of the city",
          file: ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg").signed_id
        },
        {
          title: "Picture of another city",
          file: ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city2.jpeg", "image/jpeg"), filename: "city2.jpeg").signed_id
        }
      ]
    end
    let(:photos) { [] }

    it "creates a gallery for the resource" do
      expect { command.call }.to change(Decidim::Attachment, :count).by(uploaded_photos.count)
      resource = resource_class.last
      expect(resource.photos.count).to eq(2)
      last_attachment = Decidim::Attachment.last
      expect(last_attachment.attached_to).to eq(resource)
    end

    context "when gallery is left blank" do
      let(:uploaded_photos) { [] }

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when images are removed" do
      let!(:image1) { create(:attachment, :with_image, attached_to: resource) }
      let!(:image2) { create(:attachment, :with_image, attached_to: resource) }
      let(:uploaded_photos) { [] }
      let(:current_photos) { [image1] }

      it "to decrease the number of photos in the gallery" do
        expect(resource.attachments.count).to eq(2)
        expect(resource.photos.count).to eq(2)
        expect { command.call }.to change(Decidim::Attachment, :count).by(-1)
        expect(resource.attachments.count).to eq(1)
        expect(resource.photos.count).to eq(1)
      end
    end
  end
end

shared_examples "admin destroys resource gallery" do
  it "destroys the attached image" do
    expect { command.call }.to change(Decidim::Attachment, :count).by(-1)
  end
end
