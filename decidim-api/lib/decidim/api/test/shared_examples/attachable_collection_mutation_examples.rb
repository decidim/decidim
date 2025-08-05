# frozen_string_literal: true

RSpec.shared_examples "attachable collection mutations" do
  let!(:collection_for) { model }
  let!(:attachment_collections) { create_list(:attachment_collection, 2, collection_for:) }
  let(:attributes) do
    {
      name:,
      description:,
      weight:,
      key:
    }
  end
  let(:name) { generate_localized_title }
  let(:description) { generate_localized_title }
  let(:key) { "testing" }
  let(:slug) { key }
  let(:weight) { 999 }

  describe "#create" do
    let!(:type_class) { Decidim::Core::CreateAttachmentCollectionType }
    let(:variables) do
      {
        input: {
          attributes: attributes
        }
      }
    end
    let(:query) do
      <<~GRAPHQL
        mutation($input: CreateAttachmentCollectionInput!) {
          createAttachmentCollection(input: $input) {
            id
            name {
              translation(locale: "en")
            }
            description {
              translation(locale: "en")
            }
            weight
            key
          }
        }
      GRAPHQL
    end
    let(:api_response) { response["createAttachmentCollection"] }

    it "does not create attachment collection for unauthorized user" do
      expect(api_response).to be_nil
    end

    context "with an admin user" do
      let(:user_type) { :admin }

      include_examples "creatable attachment collection"
    end

    context "with an API user" do
      let(:user_type) { :api_user }

      include_examples "creatable attachment collection"
    end
  end

  describe "#update" do
    let(:collection) { attachment_collections.first }
    let!(:type_class) { Decidim::Core::UpdateAttachmentCollectionType }
    let(:api_response) { response["updateAttachmentCollection"] }
    let(:variables) do
      {
        input: {
          id: collection.id,
          attributes: attributes
        }
      }
    end
    let(:query) do
      <<~GRAPHQL
        mutation($input: UpdateAttachmentCollectionInput!) {
          updateAttachmentCollection(input: $input) {
            id
            name {
              translation(locale: "en")
            }
            description {
              translation(locale: "en")
            }
            weight
            key
          }
        }
      GRAPHQL
    end

    it "does not update attachment collection for unauthorized user" do
      expect(api_response).to be_nil
    end

    context "with an admin user" do
      let(:user_type) { :admin }

      include_examples "updatable attachment collection"
    end

    context "with an API user" do
      let(:user_type) { :api_user }

      include_examples "updatable attachment collection"
    end
  end

  describe "#delete" do
    let(:collection) { attachment_collections.first }
    let!(:type_class) { Decidim::Core::DeleteAttachmentCollectionType }
    let(:query) do
      %( mutation { deleteAttachmentCollection(id: #{collection.id}) { id } })
    end
    let(:api_response) { response["deleteAttachmentCollection"] }

    it "does not update attachment for unauthorized user" do
      expect(api_response).to be_nil
    end

    context "with an admin user" do
      let(:user_type) { :admin }

      include_examples "deletable attachment collection"
    end

    context "with an API user" do
      let(:user_type) { :api_user }

      include_examples "deletable attachment collection"
    end
  end
end

shared_examples_for "creatable attachment collection" do
  it "creates an attachment collection" do
    expect { response }.to change(Decidim::AttachmentCollection, :count).by(1)
  end

  it "creates an action log record" do
    expect { response }.to change(Decidim::ActionLog, :count).by(1)
  end

  it "sets all the attributes for the created attachment collection" do
    ac = Decidim::AttachmentCollection.find(api_response["id"])
    expect(ac.name).to eq(name)
    expect(ac.key).to eq(key)
    expect(ac.description).to eq(description)
    expect(ac.weight).to eq(weight)
    expect(ac.collection_for).to eq(model)
  end

  it "returns the created attachment collection" do
    ac = Decidim::AttachmentCollection.find(api_response["id"])
    expect(api_response).to include(
      {
        "id" => ac.id.to_s,
        "name" => { "translation" => name["en"] },
        "description" => { "translation" => description["en"] },
        "weight" => weight,
        "key" => key
      }
    )
  end

  context "when the key is provided as 'slug'" do
    let(:attributes) do
      {
        name:,
        description:,
        weight:,
        slug:
      }
    end

    it "sets all the attributes for the created attachment collection" do
      ac = Decidim::AttachmentCollection.find(api_response["id"])
      expect(ac.name).to eq(name)
      expect(ac.key).to eq(key)
      expect(ac.description).to eq(description)
      expect(ac.weight).to eq(weight)
      expect(ac.collection_for).to eq(model)
    end
  end

  context "when weight is not provided" do
    let(:attributes) do
      {
        name:,
        description:,
        key:
      }
    end

    it "sets it to zero" do
      ac = Decidim::AttachmentCollection.find(api_response["id"])
      expect(ac.weight).to eq(0)
    end
  end

  context "when description is not provided" do
    let(:attributes) do
      {
        name:,
        weight:,
        key:
      }
    end

    it "raises an error" do
      expect { response }.to raise_error(StandardError)
    end
  end

  context "when key is not provided" do
    let(:attributes) do
      {
        name:,
        description:,
        weight:
      }
    end

    it "sets it to nil" do
      ac = Decidim::AttachmentCollection.find(api_response["id"])
      expect(ac.key).to be_nil
    end
  end
end

shared_examples_for "updatable attachment collection" do
  it "creates an action log record" do
    expect { response }.to change(Decidim::ActionLog, :count).by(1)
  end

  it "updates all the attributes for the updated attachment collection" do
    response
    collection.reload
    expect(collection.name.except("machine_translations")).to eq(name)
    expect(collection.description.except("machine_translations")).to eq(description)
    expect(collection.key).to eq(key)
    expect(collection.weight).to eq(weight)
    expect(collection.collection_for).to eq(model)
  end

  it "returns the updated attachment collection" do
    response
    collection.reload
    expect(api_response).to include(
      {
        "id" => collection.id.to_s,
        "name" => { "translation" => name["en"] },
        "description" => { "translation" => description["en"] },
        "weight" => weight,
        "key" => key
      }
    )
  end

  context "when the key is provided as 'slug'" do
    let(:attributes) do
      {
        name:,
        description:,
        weight:,
        slug:
      }
    end

    it "sets all the attributes for the created attachment collection" do
      response
      collection.reload
      expect(collection.name.except("machine_translations")).to eq(name)
      expect(collection.description.except("machine_translations")).to eq(description)
      expect(collection.key).to eq(key)
      expect(collection.weight).to eq(weight)
      expect(collection.collection_for).to eq(model)
    end
  end

  context "when weight is not provided" do
    let(:attributes) do
      {
        name:,
        description:,
        key:
      }
    end

    it "sets it to zero" do
      response
      collection.reload
      expect(collection.weight).to eq(0)
    end
  end

  context "when description is not provided" do
    let(:attributes) do
      {
        name:,
        weight:,
        slug:
      }
    end

    it "keeps the original description" do
      original_description = collection.description
      response
      collection.reload
      expect(collection.description).to eq(original_description)
    end
  end

  context "when key is not provided" do
    let(:attributes) do
      {
        name:,
        description:,
        weight:
      }
    end

    it "keeps the original key" do
      original_key = collection.key
      response
      collection.reload
      expect(collection.key).not_to be_empty
      expect(collection.key).to eq(original_key)
    end
  end
end

shared_examples_for "deletable attachment collection" do
  it "deletes the attachment collection" do
    expect do
      execute_query(query, variables)
    end.to change(Decidim::AttachmentCollection, :count).by(-1)
  end

  it "returns the deleted attachment collection" do
    expect(api_response).to eq({ "id" => collection.id.to_s })
  end
end
