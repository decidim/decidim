# frozen_string_literal: true

require "spec_helper"

describe Decidim::UrlHelper do
  describe "#decidim_url_params" do
    subject(:params) do
      helper.decidim_url_params(
        ActionController::Parameters.new(
          "script_name" => "javascript:alert(1)//",
          "original_script_name" => "/evil",
          "host" => "evil.example.org",
          "protocol" => "http",
          "port" => "8080",
          "only_path" => "false",
          "anchor" => "evil",
          "params" => { "foo" => "bar" },
          "path_params" => { "id" => "1" },
          "trailing_slash" => "true",
          "subdomain" => "evil",
          "domain" => "evil.example.org",
          "tld_length" => "2",
          "locale" => "en",
          "page" => "2",
          "filter" => { "with_resource_type" => "all" }
        )
      )
    end

    it "removes the Rails reserved URL options" do
      expect(params.keys).to contain_exactly("locale", "page", "filter")
    end

    it "keeps the application parameters" do
      expect(params["page"]).to eq("2")
      expect(params["filter"]["with_resource_type"]).to eq("all")
    end
  end
end
