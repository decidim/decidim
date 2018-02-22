require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe DateType, type: :graphql do
      include_context "with a graphql type"
      let(:model) { DateTime.civil(2018, 2, 22, 9, 47, 00, "+1") }
      let(:query) { nil }

      it "returns the formatted date" do
        expect(response).to eq("2018-02-22")
      end
    end
  end
end