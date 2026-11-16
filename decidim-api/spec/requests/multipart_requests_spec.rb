# frozen_string_literal: true

require "spec_helper"

# The multipart requests are handled by `ApolloUploadServer::Middleware`, which
# maps the uploaded files to the operation variables before the request reaches
# the controller. The middleware is only applied to the full request stack, so
# these checks are done through a request spec instead of a controller one.
describe "Multipart requests" do
  let(:organization) { create(:organization) }
  let(:sign_in_path) { "/api/sign_in" }
  let(:api_path) { "/api" }

  let(:query) { "mutation ($input: UploadFileInput!) { uploadFile(input: $input) { blob { id filename } } }" }
  let(:operations) { { query:, variables: { input: { file: nil } } }.to_json }
  let(:map) { { "0" => ["variables.input.file"] }.to_json }
  let(:uploaded_file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

  before do
    host! organization.host
  end

  context "with an API user" do
    let(:key) { "dummykey123456" }
    let(:secret) { "decidim123456789" }
    let!(:user) { create(:api_user, organization:, api_key: key, api_secret: secret) }
    let(:authorization) do
      post sign_in_path, params: { api_user: { key:, secret: } }
      response.headers["Authorization"]
    end

    it "executes the operation of the multipart payload with the mapped file" do
      post api_path,
           params: {
             :operations => operations,
             :map => map,
             "0" => uploaded_file
           },
           headers: {
             "Authorization" => authorization
           }

      expect(response).to have_http_status(:success)
      expect(response.parsed_body["errors"]).to be_nil
      expect(response.parsed_body.dig("data", "uploadFile", "blob", "filename")).to eq("city.jpeg")
    end
  end
end
