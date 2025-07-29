# frozen_string_literal:  true

RSpec.shared_examples "attachable mutations" do
  let!(:attached_to) { model }
  let(:other) { create(:participatory_process, organization: model.organization) }
  let!(:attachments) { create_list(:attachment, 2, attached_to:) }
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "city.jpeg",
      content_type: "image/jpeg"
    )
  end
  let(:description) { { "en" => "description" } }
  let(:title) { { "en" => "title" } }
  let(:weight) { 1 }
  let(:attributes) do
    {
      weight: weight,
      title: title,
      description: description,
      file: { blobId: blob.id }
    }
  end

  let(:variables) do
    {
      input: {
        attributes: attributes
      }
    }
  end

  describe "#create" do
    let!(:type_class) { Decidim::Core::CreateAttachmentType }
    let(:query) do
      <<~GRAPHQL
        mutation($input: CreateAttachmentInput!) {
          createAttachment(input: $input) {
            id
            title {
              translation(locale: "en")
            }
            description {
              translation(locale: "en")
            }
          }
        }
      GRAPHQL
    end
    let(:attachment_response) { response["createAttachment"] }

    it "does not create attachment for unauthorized user" do
      expect(attachment_response).to be_nil
    end

    context "with an admin user" do
      let(:user_type) { :admin }

      include_examples "creatable attachment"
    end

    context "with an API user" do
      let(:user_type) { :api_user }

      include_examples "creatable attachment"
    end
  end
end

shared_examples_for "creatable attachment" do
  it "creates an attachment" do
    expect { response }.to change(Decidim::Attachment, :count).by(1)
  end

  it "creates an action log record" do
    expect { response }.to change(Decidim::ActionLog, :count).by(1)
  end

  it "sets all the attributes for the created attachment" do
    attachment = Decidim::Attachment.find(attachment_response["id"])
    expect(attachment.title).to eq(title)
    expect(attachment.description).to eq(description)
    expect(attachment.weight).to eq(weight)
    expect(attachment.file.blob).to eq(blob)
    expect(attachment.attached_to).to eq(model)
    expect(attachment.attachment_collection).to be_nil
  end

  context "when weight is not provided" do
    let(:attributes) do
      {
        title: title,
        description: description,
        file: { blobId: blob.id }
      }
    end

    it "sets it to zero" do
      attachment = Decidim::Attachment.find(attachment_response["id"])
      expect(attachment.weight).to eq(0)
    end
  end

  context "when description is not provided" do
    let(:attributes) do
      {
        weight: weight,
        title: title,
        file: { blobId: blob.id }
      }
    end

    it "raises an error" do
      expect { response }.to raise_error(StandardError)
    end
  end

  context "when collection is provided using ID" do
    let(:attributes) do
      {
        weight: weight,
        title: title,
        description: description,
        file: { blobId: blob.id },
        collection: { id: collection.id }
      }
    end

    let(:collection) { create(:attachment_collection, collection_for: model) }

    it "sets the collection" do
      attachment = Decidim::Attachment.find(attachment_response["id"])
      expect(attachment.attachment_collection).to eq(collection)
    end

    context "and the collection belongs to another object" do
      let(:collection) { create(:attachment_collection, collection_for: other, key: "testing") }

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end

    context "and the ID is not set" do
      let(:attributes) do
        {
          weight: weight,
          title: title,
          description: description,
          file: { blobId: blob.id },
          collection: { id: nil }
        }
      end

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end
  end

  context "when collection is provided using slug" do
    let(:attributes) do
      {
        weight: weight,
        title: title,
        description: description,
        file: { blobId: blob.id },
        collection: { slug: collection.key }
      }
    end

    let!(:collection) { create(:attachment_collection, collection_for: model, key: "testing") }

    it "sets the collection" do
      attachment = Decidim::Attachment.find(attachment_response["id"])
      expect(attachment.attachment_collection).to eq(collection)
    end

    context "and the slug is not found" do
      let(:attributes) do
        {
          weight: weight,
          title: title,
          description: description,
          file: { blobId: blob.id },
          collection: { slug: "foo" }
        }
      end

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end

    context "and the collection belongs to another object" do
      let!(:collection) { create(:attachment_collection, collection_for: other) }

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end

    context "and the slug is empty" do
      let(:attributes) do
        {
          weight: weight,
          title: title,
          description: description,
          file: { blobId: blob.id },
          collection: { slug: "" }
        }
      end

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end

    context "and the slug is not set" do
      let(:attributes) do
        {
          weight: weight,
          title: title,
          description: description,
          file: { blobId: blob.id },
          collection: { slug: nil }
        }
      end

      it "does not create the attachment" do
        expect { response }.to raise_error(StandardError)
      end
    end
  end
end
