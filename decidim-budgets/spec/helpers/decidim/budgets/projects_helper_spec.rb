# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe ProjectsHelper do
      include Decidim::LayoutHelper
      include ::Devise::Test::ControllerHelpers

      let!(:organization) { create(:organization) }
      let!(:budgets_component) { create(:budgets_component, :with_geocoding_enabled, organization:) }
      let(:budget) { create(:budget, component: budgets_component) }
      let!(:user) { create(:user, organization:) }
      let!(:projects) { create_list(:project, 5, budget:, address:, latitude:, longitude:, component: budgets_component) }
      let!(:project) { projects.first }
      let(:address) { "Carrer Pic de Peguera 15, 17003 Girona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }

      describe "#has_position?" do
        subject { helper.has_position?(project) }

        it { is_expected.to be_truthy }

        context "when project is not geocoded" do
          let!(:projects) { create_list(:project, 5, budget:, address:, latitude: nil, longitude: nil, component: budgets_component) }

          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
