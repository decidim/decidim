# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim::Accountability
  describe DeleteMilestoneType, type: :graphql do
    include_context "with a graphql class mutation"

    let(:root_klass) { ResultMutationType }
    let(:component) { create(:component, manifest_name: :accountability) }
    let!(:result) { create(:result, component:) }
    let(:model) { result }
    let!(:milestone) { create(:milestone, result:) }
    let(:api_response) { response["deleteMilestone"] }

    let(:query) do
      %( mutation { deleteMilestone(id: #{milestone.id}) { id } })
    end

    context "with admin user" do
      it_behaves_like "API deletable milestone" do
        let!(:user_type) { :admin }
      end
    end

    context "with normal user" do
      it "returns nil" do
        expect(api_response).to be_nil
        expect(milestone.reload).not_to be_nil
      end
    end

    context "with api_user" do
      it_behaves_like "API deletable milestone" do
        let!(:user_type) { :api_user }
      end
    end
  end
end
