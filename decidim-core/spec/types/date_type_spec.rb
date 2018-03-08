# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe DateType, type: :graphql do
      include_context "with a graphql scalar type"
      let(:model) { DateTime.civil(2018, 2, 22, 9, 47, 0, "+1") }

      it "returns the formatted date" do
        expect(response).to eq("2018-02-22")
      end
    end
  end
end
