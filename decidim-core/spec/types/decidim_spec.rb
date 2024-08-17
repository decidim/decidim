# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql class type"
  let(:schema) { Decidim::Api::Schema }

  let(:locale) { "en" }

  let(:query) do
    %(
      query {
        decidim {
          version
          applicationName
        }
      }
    )
  end

  describe "valid query" do
    it "executes successfully" do
      expect { response }.not_to raise_error
    end

    it "has decidim" do
      expect(response["decidim"]).to eq({
                                          "applicationName" => "My Application Name",
                                          "version" => nil
                                        })
    end

    context "when disclosing system version is enabled" do
      before do
        allow(Decidim::Api).to receive(:disclose_system_version).and_return(true)
      end

      it "discloses the version number" do
        expect(response["decidim"]).to include("version" => Decidim::Core.version)
      end
    end
  end
end
