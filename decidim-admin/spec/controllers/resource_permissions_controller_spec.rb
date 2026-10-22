# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "decidim/initiatives/test/factories"
require "decidim/debates/test/factories"

module Decidim
  module Admin
    describe ResourcePermissionsController do
      subject(:resolved_resource) { controller.send(:resource) }

      let(:organization) { create(:organization) }
      let(:other_organization) { create(:organization) }
      let!(:initiatives_type) { create(:initiatives_type, organization:) }
      let!(:other_initiatives_type) { create(:initiatives_type, organization: other_organization) }
      let(:params) { {} }

      before do
        allow(controller).to receive(:current_organization).and_return(organization)
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params))
      end

      context "when the resource belongs to the current organization" do
        let(:params) { { resource_name: "initiatives_type", initiatives_type_id: initiatives_type.id } }

        it { is_expected.to eq(initiatives_type) }
      end

      context "when the resource belongs to another organization" do
        let(:params) { { resource_name: "initiatives_type", initiatives_type_id: other_initiatives_type.id } }

        it { is_expected.to be_nil }
      end

      context "when the resource does not have an organization association" do
        let!(:debate) { create(:debate) }
        let(:params) { { resource_name: "debate", debate_id: debate.id } }

        it { is_expected.to be_nil }
      end

      context "when the resource name is unknown" do
        let(:params) { { resource_name: "unknown", unknown_id: 1 } }

        it { is_expected.to be_nil }
      end

      context "when the resource name is blank" do
        let(:params) { {} }

        it { is_expected.to be_nil }
      end

      context "when the resource does not allow resource permissions" do
        let(:params) { { resource_name: "initiatives_type", initiatives_type_id: initiatives_type.id } }

        before do
          allow(Decidim::InitiativesType).to receive(:where).with(organization:).and_return(
            instance_double(ActiveRecord::Relation, find_by: initiatives_type)
          )
          allow(initiatives_type).to receive(:allow_resource_permissions?).and_return(false)
        end

        it { is_expected.to be_nil }
      end
    end
  end
end
