# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    include_context "when a resource is ready for global search"

    let(:participatory_space) { create(:participatory_process, :published, :with_steps, organization:) }
    let(:current_component) { create :proposal_component, organization:, participatory_space: }
    let!(:proposal) do
      create(
        :proposal,
        :draft,
        skip_injection: true,
        component: current_component,
        scope: scope1,
        body: description1,
        users: [author]
      )
    end

    describe "Indexing of proposals" do
      context "when implementing Searchable" do
        context "when on create" do
          context "when proposals are NOT official" do
            let(:proposal2) do
              create(:proposal, skip_injection: true, component: current_component)
            end

            it "does not index a SearchableResource after Proposal creation when it is not official" do
              searchables = SearchableResource.where(resource_type: proposal.class.name, resource_id: [proposal.id, proposal2.id])
              expect(searchables).to be_empty
            end
          end

          context "when proposals ARE official" do
            let(:author) { organization }

            before do
              proposal.update(published_at: Time.current)
            end

            it "does indexes a SearchableResource after Proposal creation when it is official" do
              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id, locale:)
                expect_searchable_resource_to_correspond_to_proposal(searchable, proposal, locale)
              end
            end
          end
        end

        context "when on update" do
          context "when it is NOT published" do
            it "does not index a SearchableResource when Proposal changes but is not published" do
              searchables = SearchableResource.where(resource_type: proposal.class.name, resource_id: proposal.id)
              expect(searchables).to be_empty
            end
          end

          context "when it IS published" do
            before do
              proposal.update published_at: Time.current
            end

            it "inserts a SearchableResource after Proposal is published" do
              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id, locale:)
                expect_searchable_resource_to_correspond_to_proposal(searchable, proposal, locale)
              end
            end

            it "updates the associated SearchableResource after published Proposal update" do
              searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id)
              created_at = searchable.created_at
              updated_title = { "en" => "Brand new title", "machine_translations" => {} }
              proposal.update(title: updated_title)

              proposal.save!
              searchable.reload

              organization.available_locales.each do |locale|
                searchable = SearchableResource.find_by(resource_type: proposal.class.name, resource_id: proposal.id, locale:)
                expect(searchable.content_a).to eq updated_title[locale.to_s].to_s
                expect(searchable.updated_at).to be > created_at
              end
            end

            it "removes the associated SearchableResource after unpublishing a published Proposal on update" do
              proposal.update(published_at: nil)

              searchables = SearchableResource.where(resource_type: proposal.class.name, resource_id: proposal.id)
              expect(searchables).to be_empty
            end
          end
        end

        context "when on destroy" do
          it "destroys the associated SearchableResource after Proposal destroy" do
            proposal.destroy

            searchables = SearchableResource.where(resource_type: proposal.class.name, resource_id: proposal.id)

            expect(searchables.any?).to be false
          end
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

        before do
          proposal.update(published_at: Time.current)
          proposal2.update(published_at: Time.current)
        end

        it "returns Proposal results" do
          Decidim::Search.call("Ow", organization, resource_type: proposal.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[proposal.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [proposal, proposal2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("wait", organization, resource_type: proposal.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[proposal.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [proposal2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_searchable_resource_to_correspond_to_proposal(searchable, proposal, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(proposal.published_at.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(proposal, locale))
    end

    def expected_searchable_resource_attrs(proposal, locale)
      {
        "content_a" => I18n.transliterate(translated(proposal.title, locale:)),
        "content_b" => "",
        "content_c" => "",
        "content_d" => I18n.transliterate(translated(proposal.body, locale:)),
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
