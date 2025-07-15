# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe DeleteResultType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { AccountabilityMutationType }
    let(:model) { create(:component, manifest_name: :accountability) }
    let!(:result) { create(:result, component: model) }

    let(:query) do
      %( mutation { deleteResult(id: #{result.id}) { id } })
    end

    context "with admin user" do
      it_behaves_like "API deletable result" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        result = response["deleteResult"]
        expect(result).to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API deletable result" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
