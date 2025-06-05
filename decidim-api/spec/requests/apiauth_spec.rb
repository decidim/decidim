# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Api authentication" do
  let(:sign_in_path) { "/api/sign_in" }
  let(:sign_out_path) { "/api/sign_out" }
  let(:organization) { create(:organization) }
  let(:query) { "{session { user { id nickname } } }" }

  before do
    host! organization.host
  end

  context "with api user" do
    let(:key) { "dummykey123456" }
    let(:secret) { "decidim123456789" }
    let!(:user) { create(:api_user, organization: organization, api_key: key, api_secret: secret) }
    let(:params) do
      {
        api_user: {
          key: key,
          secret: secret
        }
      }
    end
    let(:hacker_key) { "fakekey123456" }
    let(:invalid_params) do
      {
        api_user: {
          key: hacker_key,
          secret: "incorrect_secret"
        }
      }
    end

    it "signs in" do
      post sign_in_path, params: params
      expect(response.headers["Authorization"]).to be_present
      expect(response.body["jwt_token"]).to be_present
      parsed_response_body = JSON.parse(response.body)
      expect(response.headers["Authorization"]).to eq("Bearer #{parsed_response_body["jwt_token"]}")
    end

    it "renders resource when invalid credentials" do
      post sign_in_path, params: invalid_params

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["id"]).not_to be_present
      expect(parsed_response["jwt_token"]).not_to be_present
    end

    it "signs out" do
      post sign_in_path, params: params
      expect(response).to have_http_status(:ok)
      authorization = response.headers["Authorization"]
      original_count = Decidim::Api::JwtDenylist.count
      delete sign_out_path, params: {}, headers: { HTTP_AUTHORIZATION: authorization }
      expect(Decidim::Api::JwtDenylist.count).to eq(original_count + 1)
    end

    context "when signed in" do
      before do
        post sign_in_path, params: params
      end

      it "can use token to post to api" do
        authorization = response.headers["Authorization"]
        post "/api", params: { query: "{session { user { id nickname } } }" }, headers: { HTTP_AUTHORIZATION: authorization }
        parsed_response = JSON.parse(response.body)["data"]
        expect(parsed_response).to match(
          "session" => {
            "user" => { "id" => user.id.to_s, "nickname" => "@#{user.nickname}" }
          }
        )
      end
    end

    context "when not signed in" do
      it "does not return session details" do
        post "/api", params: { query: query }
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to match("data" => { "session" => nil })
      end
    end
  end

  context "with normal user" do
    let(:password) { "decidim123456789" }
    let!(:user) { create(:user, :confirmed, organization: organization, password:) }
    let(:params) do
      {
        user: {
          email: user.email,
          password:
        }
      }
    end

    it "does not authenticate user" do
      post sign_in_path, params: params

      parsed_response = JSON.parse(response.body)
      anonymized_key = parsed_response["api_key"]
      expect(anonymized_key).to be_nil
      expect(parsed_response["jwt_token"]).not_to be_present
    end
  end
end
