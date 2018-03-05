# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    subject { described_class.new(params) }

    let(:current_feature) { create :feature, manifest_name: "meetings" }
    let(:organization) { current_feature.organization }
    let(:scope1) { create :scope, organization: organization }
    let!(:meeting) do
      create(
        :meeting,
        feature: current_feature,
        scope: scope1,
        title: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt."),
        description: Decidim::Faker::Localized.literal("Nulla TestCheck accumsan tincidunt description."),
        address: "Some very centric address"
      )
    end

    describe "Indexing of meetings" do
      context "when implementing Searchable" do
        it "inserts a SearchableRsrc after Meeting creation" do
          organization.available_locales.each do |locale|
            searchable = SearchableRsrc.find_by(resource_type: meeting.class.name, resource_id: meeting.id, locale: locale)
            expect_searchable_rsrc_to_correspond_to_meeting(searchable, meeting, locale)
          end
        end
        it "updates the associated SearchableRsrc after Meeting update" do
          searchable = SearchableRsrc.find_by(resource_type: meeting.class.name, resource_id: meeting.id)
          created_at = searchable.created_at
          updated_title = organization.available_locales.inject({}) do |modifs, locale|
            meeting.title[locale] += locale.upcase
            modifs.update(locale => meeting.title[locale])
          end

          meeting.save!

          organization.available_locales.each do |locale|
            searchable = SearchableRsrc.find_by(resource_type: meeting.class.name, resource_id: meeting.id, locale: locale)
            expect(searchable.content_a).to eq updated_title[locale]
            expect(searchable.updated_at).to be > created_at
          end
        end
        it "destroys the associated SearchableRsrc after Meeting destroy" do
          meeting.destroy

          searchables = SearchableRsrc.where(resource_type: meeting.class.name, resource_id: meeting.id)

          expect(searchables.any?).to be false
        end
      end
    end

    describe "Search" do
      context "when searching by Meeting resource_type" do
        it "returns Meeting results" do
          Decidim::Search.call("Nulla", organization, resource_type: meeting.class.name) do
            on(:ok) do |results|
              expect(results.count).to eq(organization.available_locales.size)
              results.each { |result| expect(result.resource).to eq meeting }
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    #--------------------------------------------------------------------

    private

    #--------------------------------------------------------------------

    def expect_searchable_rsrc_to_correspond_to_meeting(searchable, meeting, locale)
      attrs = searchable.attributes
      attrs.delete("id")
      attrs.delete("created_at")
      attrs.delete("updated_at")
      expect(attrs).to eq(expected_searchable_rsrc_attrs(meeting, locale))
    end

    def expected_searchable_rsrc_attrs(meeting, locale)
      {
        "content_a" => meeting.title[locale],
        "content_b" => nil,
        "content_c" => nil,
        "content_d" => [meeting.description[locale], meeting.address].join(" "),
        "locale" => locale,

        "decidim_organization_id" => meeting.feature.organization.id,
        "decidim_participatory_space_id" => current_feature.participatory_space_id,
        "decidim_participatory_space_type" => current_feature.participatory_space_type,
        "decidim_scope_id" => meeting.decidim_scope_id,
        "resource_id" => meeting.id,
        "resource_type" => "Decidim::Meetings::Meeting"
      }
    end
  end
end
