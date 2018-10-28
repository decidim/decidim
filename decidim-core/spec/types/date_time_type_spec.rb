# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe DateTimeType, type: :graphql do
      include_context "with a graphql scalar type"
      let(:model) { Time.new(2018, 2, 22, 9, 47, 0, "+01:00") }

      it "returns the formatted date" do
        expect(response).to eq("2018-02-22T09:47:00+01:00")
      end
    end
  end
end
