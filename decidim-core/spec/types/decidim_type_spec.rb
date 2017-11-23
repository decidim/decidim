# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  describe DecidimType do
    include_context "with a graphql type"

    let(:model) do
      Decidim
    end

    describe "version" do
      let(:query) { "{ version }" }

      it "returns the version" do
        expect(response).to eq("version" => Decidim.version)
      end
    end

    describe "application_name" do
      let(:query) { "{ application_name }" }

      it "returns the application's name" do
        expect(response).to eq("application_name" => Decidim.application_name)
      end
    end
  end
end
