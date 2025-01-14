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

      describe "#project_data_for_map" do
        subject { helper.project_data_for_map(project) }

        let(:fake_description) { "<script>alert(\"HEY\")</script> This is my long, but still super interesting, description of my also long, but also super interesting, project. Check it out!" }
        let(:fake_title) { "<script>alert(\"HEY\")</script> This is my title" }

        it "returns preview data" do
          allow(project).to receive(:description).and_return(en: fake_description)
          allow(project).to receive(:title).and_return(en: fake_title)

          expect(subject["latitude"]).to eq(latitude)
          expect(subject["longitude"]).to eq(longitude)
          expect(subject["title"]).to eq("&lt;script&gt;alert(&quot;HEY&quot;)&lt;/script&gt; This is my title")
          expect(subject["link"]).to eq(::Decidim::ResourceLocatorPresenter.new([project.budget, project]).path)
        end
      end
    end
  end
end
