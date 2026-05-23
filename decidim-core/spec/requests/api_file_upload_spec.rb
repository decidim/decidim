# frozen_string_literal: true

require "spec_helper"
require "tempfile"
require "decidim/api/test"

RSpec.describe "UploadFile Mutation" do
  let(:sign_in_path) { "/api/sign_in" }
  let(:sign_out_path) { "/api/sign_out" }
  let(:api_path) { "/api" }
  let(:organization) { create(:organization) }
  let(:query) do
    <<~GRAPHQL
      mutation($input: UploadFileInput!) {#{" "}
        uploadFile(input: $input) {#{" "}
          blob { id filename byteSize signedId checksum }#{" "}
        }#{" "}
      }
    GRAPHQL
  end

  let(:tempfile) { Tempfile.create(["foo", ".jpg"]) }
  let(:file) do
    Rack::Test::UploadedFile.new(tempfile.path, "image/jpg")
  end
  let(:operations) do
    {
      query:,
      variables:
    }.to_json
  end
  let(:map) do
    { "0" => ["variables.input.file"] }.to_json
  end

  let(:variables) do
    { input: { file: nil } }
  end

  before do
    host! organization.host
  end

  context "with an API user" do
    let(:key) { "dummykey123456" }
    let(:secret) { "decidim123456789" }
    let!(:user) { create(:api_user, organization:, api_key: key, api_secret: secret) }
    let(:params) do
      {
        api_user: {
          key:,
          secret:
        }
      }
    end

    let(:authorization) do
      post(sign_in_path, params:)
      response.headers["Authorization"]
    end

    it "uploads the file successfully" do
      post api_path,
           params: {
             :operations => operations,
             :map => map,
             "0" => file
           },
           headers: {
             "Authorization" => authorization
           }
      json = response.parsed_body
      blob_data = json.dig("data", "uploadFile", "blob")
      blob = ActiveStorage::Blob.last
      expect(blob_data).to include(
        "id" => blob.id.to_s,
        "filename" => blob.filename,
        "checksum" => blob.checksum,
        "signedId" => blob.signed_id,
        "byteSize" => blob.byte_size
      )
    end
  end

  it "does not upload for unauthorized user" do
    post api_path,
         params: {
           :operations => operations,
           :map => map,
           "0" => file
         },
         headers: {
           "Authorization" => "Bearer Fake Authorization"
         }
    json = response.parsed_body
    blob_data = json.dig("data", "uploadFile", "blob")
    expect(blob_data).to be_nil
  end
end
