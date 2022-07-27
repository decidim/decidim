# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:current_component) { create :debates_component, manifest_name: "debates" }
    let(:organization) { current_component.organization }
    let(:author) { create(:user, organization:) }
    let!(:debate) do
      desc = "Nulla TestCheck accumsan tincidunt description Ow!"
      create(
        :debate,
        :open_ama,
        component: current_component,
        title: Decidim::Faker::Localized.name,
        description: { ca: "CA:#{desc}", en: "EN:#{desc}", es: "ES:#{desc}" },
        author:
      )
    end

    describe "Indexing of debates" do
      context "when implementing Searchable" do
        context "when on create" do
          context "when debates are NOT official" do
            it "does indexes a SearchableResource after Debate creation when it is not official" do
              expect_resource_to_be_indexed_for_global_search(debate)
            end
          end

          context "when debates ARE official" do
            let(:author) { organization }

            it "does indexes a SearchableResource after Debate creation when it is official" do
              expect_resource_to_be_indexed_for_global_search(debate)
            end
          end
        end

        context "when on update" do
          before do
            debate.update title: "#{debate.title}+update"
          end

          it "updates the associated SearchableResource after Debate update" do
            searchable = SearchableResource.find_by(resource_type: debate.class.name, resource_id: debate.id)
            created_at = searchable.created_at
            updated_title = { "en" => "Brand new title" }
            debate.update(title: updated_title)

            debate.save!
            searchable.reload

            organization.available_locales.each do |locale|
              searchable = SearchableResource.find_by(resource_type: debate.class.name, resource_id: debate.id, locale:)
              expect(searchable.content_a).to eq updated_title[locale.to_s].to_s
              expect(searchable.updated_at).to be > created_at
            end
          end
        end

        context "when on destroy" do
          it "destroys the associated SearchableResource after Debate destroy" do
            debate.destroy
            searchables = SearchableResource.where(resource_type: debate.class.name, resource_id: debate.id)
            expect(searchables.any?).to be false
          end
        end
      end
    end

    describe "Search" do
      context "when searching by Debate resource_type" do
        let!(:debate2) do
          create(
            :debate,
            component: current_component,
            title: Decidim::Faker::Localized.name,
            description: { en: "Chewie, I'll be waiting for your signal. Take care, you two. May the Force be with you. Ow!" }
          )
        end

        before do
          debate.update(title: "#{debate.title}+1")
          debate2.update(title: "#{debate.title}+2")
        end

        it "returns Debate results" do
          Decidim::Search.call("Ow", organization, resource_type: debate.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[debate.class.name]
              expect(results[:count]).to eq 2
              expect(results[:results]).to match_array [debate, debate2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "allows searching by prefix characters" do
          Decidim::Search.call("wait", organization, resource_type: debate.class.name) do
            on(:ok) do |results_by_type|
              results = results_by_type[debate.class.name]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [debate2]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    private

    def expect_resource_to_be_indexed_for_global_search(resource)
      organization.available_locales.each do |locale|
        searchable = SearchableResource.find_by(resource_type: resource.class.name, resource_id: resource.id, locale:)
        expect_searchable_resource_to_correspond_to_debate(searchable, resource, locale)
      end
    end

    def expect_searchable_resource_to_correspond_to_debate(searchable, debate, locale)
      attrs = searchable.attributes.clone
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs.delete("datetime").to_s(:short)).to eq(debate.start_time.to_s(:short))
      expect(attrs).to eq(expected_searchable_resource_attrs(debate, locale))
    end

    def expected_searchable_resource_attrs(debate, locale)
      {
        "content_a" => I18n.transliterate(translated(debate.title, locale:)),
        "content_b" => "",
        "content_c" => "",
        "content_d" => I18n.transliterate(translated(debate.description, locale:)),
        "locale" => locale,
        "decidim_organization_id" => debate.component.organization.id,
        "decidim_participatory_space_id" => current_component.participatory_space_id,
        "decidim_participatory_space_type" => current_component.participatory_space_type,
        "decidim_scope_id" => nil,
        "resource_id" => debate.id,
        "resource_type" => "Decidim::Debates::Debate"
      }
    end
  end
end
