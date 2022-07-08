# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe ProjectsHelper do
      include Decidim::LayoutHelper

      let!(:organization) { create(:organization) }
      let!(:budgets_component) { create(:budgets_component, :with_geocoding_enabled, organization: organization) }
      let(:budget) { create(:budget, component: budgets_component) }
      let!(:user) { create(:user, organization: organization) }
      let!(:projects) { create_list(:project, 5, budget: budget, address: address, latitude: latitude, longitude: longitude, component: budgets_component) }
      let!(:project) { projects.first }
      let(:address) { "Carrer Pic de Peguera 15, 17003 Girona" }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:redesign_enabled) { false }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(ActionView::Base).to receive(:redesign_enabled?).and_return(redesign_enabled)
        # rubocop:enable RSpec/AnyInstance
      end

      describe "#has_position?" do
        subject { helper.has_position?(project) }

        it { is_expected.to be_truthy }

        context "when project is not geocoded" do
          let!(:projects) { create_list(:project, 5, budget: budget, address: address, latitude: nil, longitude: nil, component: budgets_component) }

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
          expect(subject["address"]).to eq(address)
          expect(subject["title"]).to eq("&lt;script&gt;alert(&quot;HEY&quot;)&lt;/script&gt; This is my title")
          expect(subject["description"]).to eq("<div class=\"ql-editor ql-reset-decidim\">alert(&quot;HEY&quot;) This is my long, but still super interesting, description of my also long, but also sup...</div>")
          expect(subject["link"]).to eq(::Decidim::ResourceLocatorPresenter.new([project.budget, project]).path)
          expect(subject["icon"]).to match(/<svg.+/)
        end
      end

      describe "#projects_data_for_map" do
        subject { helper.projects_data_for_map(projects) }

        it "returns preview data" do
          expect(subject.length).to eq(5)
        end
      end
    end
  end
end
