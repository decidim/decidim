# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectSerializer do
    let(:budget) { create(:budget, component:) }
    let(:serialized) { subject.run }
    let(:attachment) { create(:attachment, attached_to: project) }
    let(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: project.participatory_space) }
    let(:proposals) { create_list(:proposal, 3, component: proposals_component) }
    let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: budget.component.organization) }
    let(:project) { create(:project, budget:, taxonomies:) }
    let(:router) { Decidim::EngineRouter.main_proxy(budget.component) }
    let(:component) { create(:budgets_component) }

    subject { described_class.new(project) }

    describe "#serializer" do
      before { project.link_resources(proposals, "included_proposals") }

      it "includes the id" do
        expect(serialized).to include(id: project.id)
      end

      it "includes the taxonomies" do
        expect(serialized[:taxonomies].length).to eq(2)
        expect(serialized[:taxonomies][:id]).to match_array(taxonomies.map(&:id))
        expect(serialized[:taxonomies][:name]).to match_array(taxonomies.map(&:name))
      end

      it "includes the participatory space" do
        expect(serialized[:participatory_space]).to include(id: project.budget.component.participatory_space.id)
        expect(serialized[:participatory_space]).to include(url: Decidim::ResourceLocatorPresenter.new(project.participatory_space).url)
      end

      it "includes the component" do
        expect(serialized[:component]).to include(id: project.component.id)
      end

      it "includes the title" do
        expect(serialized[:title]).to include(project.title)
      end

      it "includes the description" do
        expect(serialized[:description]).to include(project.description)
      end

      it "includes the budget" do
        expect(serialized[:budget]).to eq(
          id: project.budget.id,
          title: project.budget.title,
          url: router.budget_url(project.budget)
        )
      end

      it "includes the budget amount" do
        expect(serialized[:budget_amount]).to eq(project.budget_amount)
      end

      it "includes comment count" do
        expect(serialized[:comments]).to eq(project.comments.count)
      end

      it "includes the created at" do
        expect(serialized).to include(created_at: project.created_at)
      end

      it "includes the url" do
        expect(serialized[:url]).to eq(project.polymorphic_resource_url({}))
      end

      it "serializes the address" do
        expect(serialized).to include(address: project.address)
      end

      it "includes related proposal ids" do
        expect(serialized[:related_proposals]).to match_array(project.linked_resources(:proposals, "included_proposals").map(&:id))
      end

      it "includes related proposal titles" do
        expect(serialized[:related_proposal_titles]).to include(proposals.first.title["en"])
        expect(serialized[:related_proposal_titles]).to include(proposals.second.title["en"])
        expect(serialized[:related_proposal_titles]).to include(proposals.last.title["en"])
      end

      it "includes related proposal urls" do
        expect(serialized[:related_proposal_urls]).to include(Decidim::ResourceLocatorPresenter.new(proposals.first).url)
        expect(serialized[:related_proposal_urls]).to include(Decidim::ResourceLocatorPresenter.new(proposals.second).url)
        expect(serialized[:related_proposal_urls]).to include(Decidim::ResourceLocatorPresenter.new(proposals.last).url)
      end

      it "includes the updated date" do
        expect(serialized).to include(updated_at: project.updated_at)
      end

      it "includes the follows count" do
        expect(serialized).to include(follows_count: project.follows_count)
      end

      it "includes the selected date" do
        expect(serialized).to include(selected_at: project.selected_at)
      end

      it "serializes the reference" do
        expect(serialized).to include(reference: project.reference)
      end

      it "serializes the latitude" do
        expect(serialized).to include(latitude: project.latitude)
      end

      it "serializes the longitude" do
        expect(serialized).to include(longitude: project.longitude)
      end
    end

    context "when subscribed to the serialize event" do
      before do
        I18n.backend.store_translations(
          :en,
          decidim: {
            open_data: {
              help: {
                projects: {
                  test_field: "Test field for projects serializer subscription"
                }
              }
            }
          }
        )
      end

      ActiveSupport::Notifications.subscribe("decidim.serialize.budgets.project_serializer") do |_event_name, data|
        data[:serialized_data][:test_field] = "Resource class: #{data[:resource].class}"
      end

      it "includes new field" do
        expect(serialized[:test_field]).to eq("Resource class: Decidim::Budgets::Project")
      end
    end

    context "when show votes is disabled" do
      it "does not include count of confirmed votes" do
        expect(serialized[:confirmed_votes]).to be_nil
      end
    end

    context "when show votes is enabled" do
      let(:component) { create(:budgets_component, :with_show_votes_enabled) }

      it "includes count of confirmed votes" do
        expect(serialized[:confirmed_votes]).to eq(project.confirmed_orders_count)
      end
    end
  end
end
