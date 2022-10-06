# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe ProjectSerializer do
    let(:budget) { create(:budget) }
    let(:serialized) { subject.run }
    let(:attachment) { create :attachment, attached_to: project }
    let(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: project.participatory_space) }
    let(:proposals) { create_list(:proposal, 3, component: proposals_component) }
    let(:category) { create(:category, participatory_space: budget.component.participatory_space) }
    let(:scope) { create(:scope, organization: category.participatory_space.organization) }
    let(:project) { create(:project, budget:, category:, scope:) }

    subject { described_class.new(project) }

    describe "#serializer" do
      before { project.link_resources(proposals, "included_proposals") }

      it "includes the id" do
        expect(serialized).to include(id: project.id)
      end

      it "includes the category" do
        expect(serialized[:category]).to include(id: category.id)
        expect(serialized[:category]).to include(name: category.name)
      end

      it "includes the scope" do
        expect(serialized[:scope]).to include(id: project.scope.id)
        expect(serialized[:scope]).to include(name: project.scope.name)
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

      it "includes the budget id" do
        expect(serialized[:budget]).to eq(id: project.budget.id)
      end

      it "includes the budget amount" do
        expect(serialized[:budget_amount]).to eq(project.budget_amount)
      end

      it "includes count of confirmed votes" do
        expect(serialized[:confirmed_votes]).to eq(project.confirmed_orders_count)
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
    end

    context "when subscribed to the serialize event" do
      ActiveSupport::Notifications.subscribe("decidim.serialize.budgets.project_serializer") do |_event_name, data|
        data[:serialized_data][:test_field] = "Resource class: #{data[:resource].class}"
      end

      it "includes new field" do
        expect(serialized[:test_field]).to eq("Resource class: Decidim::Budgets::Project")
      end
    end
  end
end
