# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:current_component) { create :proposal_component, manifest_name: "proposals" }
    let(:organization) { current_component.organization }
    let(:scope1) { create :scope, organization: organization }
    let!(:proposal) do
      create(
        :proposal,
        component: current_component,
        scope: scope1,
        title: "Nulla TestCheck accumsan tincidunt.",
        body: "Nulla TestCheck accumsan tincidunt description Ow!"
      )
    end

    describe "Indexing of proposals" do
      context "when implementing Searchable" do
        it "inserts a SearchableResource after Proposal creation" do
          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id, locale: locale)
            expect_searchable_rsrc_to_correspond_to_proposal(searchable, proposal, locale)
          end
        end

        it "updates the associated SearchableResource after Proposal update" do
          searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id)
          created_at = searchable.created_at
          updated_title = "Brand new title"
          proposal.update(title: updated_title)

          proposal.save!

          organization.available_locales.each do |locale|
            searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id, locale: locale)
            expect(searchable.content_a).to eq updated_title
            expect(searchable.updated_at).to be > created_at
          end
        end

        it "destroys the associated SearchableResource after Proposal destroy" do
          proposal.destroy

          searchables = SearchableResource.where(resource_type: proposal.class.name, resource_id: proposal.id)

          expect(searchables.any?).to be false
        end
      end
    end

    describe "Search" do
      context "when searching by Proposal resource_type" do
        let!(:proposal2) do
          create(
            :proposal,
            component: current_component,
            scope: scope1,
            title: Decidim::Faker.name,
            body: "Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!"
          )
        end

        it "returns Proposal results" do
          Decidim::Search.call("Ow", organization, resource_type: proposal.class.name) do
            on(:ok) do |results|
              expect(results.count).to eq 2
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_rsrc_to_correspond_to_proposal(searchable, proposal, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(proposal.published_at.to_s(:short))
      expect(attrs).to eq(expected_searchable_rsrc_attrs(proposal, locale))
    end

    def expected_searchable_rsrc_attrs(proposal, locale)
      {
        "content_a" => proposal.title,
        "content_b" => "",
        "content_c" => "",
        "content_d" => proposal.body,
        "locale" => locale,

        "decidim_organization_id" => proposal.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => proposal.decidim_scope_id,
        "resource_id" => proposal.id,
        "resource_type" => "Decidim::Proposals::Proposal"
      }
    end
  end
end
