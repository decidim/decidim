# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FreeResourceAuthorizationModalsController do
    subject(:resolved_resource) { controller.send(:resource) }

    let(:organization) { create(:organization) }
    let(:other_organization) { create(:organization) }
    let!(:user) { create(:user, organization:) }
    let!(:other_user) { create(:user, organization: other_organization) }
    let(:params) { {} }

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params))
    end

    context "when the resource belongs to the current organization" do
      let(:params) { { resource_name: "user", resource_id: user.id } }

      it { is_expected.to eq(user) }
    end

    context "when the resource belongs to another organization" do
      let(:params) { { resource_name: "user", resource_id: other_user.id } }

      it { is_expected.to be_nil }
    end

    context "when the resource does not have an organization association" do
      let!(:dummy_resource) { create(:dummy_resource) }
      let(:params) { { resource_name: "dummy", resource_id: dummy_resource.id } }

      it { is_expected.to be_nil }
    end

    context "when the resource name is unknown" do
      let(:params) { { resource_name: "unknown", resource_id: 1 } }

      it { is_expected.to be_nil }
    end
  end
end
