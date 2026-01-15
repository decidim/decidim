# frozen_string_literal: true

require "spec_helper"

describe "Accountability component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:accountability_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization:) }

  describe "on edit", type: :system do
    let(:edit_component_path) do
      Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
    end

    before do
      switch_to_host(organization.host)
      login_as current_user, scope: :user
    end

    context "when comments_max_length is empty" do
      it_behaves_like "has mandatory config setting", :comments_max_length
    end
  end

  describe "hooks" do
    let!(:results) { create_list(:result, 5, component:) }

    describe "publish" do
      let(:component) { create(:accountability_component, published_at: nil) }

      it "adds the results to search index" do
        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
        component.publish!

        perform_enqueued_jobs do
          component.manifest.run_hooks(:publish, component)
        end

        expect(Decidim::SearchableResource.where(resource: results)).to be_present
        # 3 languages multiplied by 5 results
        expect(Decidim::SearchableResource.where(resource: results).count).to eq(15)
      end
    end

    describe "unpublish" do
      it "removes the results from search index" do
        # 3 languages multiplied by 5 results
        expect(Decidim::SearchableResource.where(resource: results).count).to eq(15)
        expect(Decidim::SearchableResource.where(resource: results)).to be_present
        component.unpublish!

        perform_enqueued_jobs do
          component.manifest.run_hooks(:publish, component)
        end

        expect(Decidim::SearchableResource.where(resource: results)).to be_empty
      end
    end
  end
end
