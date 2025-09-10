# frozen_string_literal: true

require "spec_helper"

module Decidim
  module System
    describe ApiUserForm do
      subject { described_class.from_params(attributes) }

      let(:organization) { create(:organization) }
      let(:name) { "Dummy name" }
      let(:organization_id) { organization.id }

      let(:attributes) do
        {
          name: name,
          organization: organization_id
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when name is empty" do
        let(:name) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when name is already exist" do
        let!(:api_user) { create(:api_user, organization: organization, name: name) }

        it { is_expected.not_to be_valid }
      end

      context "when organization is empty" do
        let(:organization_id) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
