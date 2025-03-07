# frozen_string_literal: true

shared_examples "api authenticatable user" do
  it "signs in" do
    post sign_in_path, params: params
    expect(response.headers["Authorization"]).to be_present
    expect(response.body["jwt_token"]).to be_present
    parsed_response_body = JSON.parse(response.body)
    expect(response.headers["Authorization"].split[1]).to eq(parsed_response_body["jwt_token"])
  end

  it "renders resource when invalid credentials" do
    post sign_in_path, params: invalid_params

    parsed_response = JSON.parse(response.body)
    anonymized_key = parsed_response["api_key"] || parsed_response["email"]
    expect(anonymized_key).to eq(hacker_key)
    expect(parsed_response["jwt_token"]).not_to be_present
  end

  it "signs out" do
    post sign_in_path, params: params
    expect(response).to have_http_status(:ok)
    authorization = response.headers["Authorization"]
    original_count = Decidim::Api::JwtBlacklist.count
    delete sign_out_path, params: {}, headers: { HTTP_AUTHORIZATION: authorization }
    expect(Decidim::Api::JwtBlacklist.count).to eq(original_count + 1)
  end

  context "when signed in" do
    before do
      post sign_in_path, params: params
    end

    it "can use token to post to api" do
      authorization = response.headers["Authorization"]
      post "/api", params: { query: "{session { user { id nickname } } }"  }, headers: { HTTP_AUTHORIZATION: authorization }
      parsed_response = JSON.parse(response.body)["data"]
      expect(parsed_response["session"]["user"]["id"].to_i).to eq(user.id)
      expect(parsed_response["session"]["user"]["nickname"]).to eq(user.nickname.prepend("@"))
    end
  end

  context "when not signed in" do
    it "does not connect to the api" do
      post "/api", params: { query: query }
      parsed_response = response.body
      expect(parsed_response).to eq("{\"data\":{\"session\":null}}")
    end
  end
end
