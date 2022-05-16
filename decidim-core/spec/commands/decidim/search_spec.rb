# frozen_string_literal: true

require "spec_helper"

describe Decidim::Search do
  let(:current_organization) { create(:organization) }

  context "with resources from different organizations" do
    let(:other_organization) { create(:organization) }
    let(:term) { "fire" }
    let(:fake_type) { "Decidim::DoesNot::Exist" }
    let!(:result) do
      create(:searchable_resource, organization: current_organization, content_a: "Fight fire with fire")
    end
    let!(:non_searchable_resource) do
      create(:searchable_resource, organization: current_organization, resource_type: fake_type, content_a: "Where's your crown king nothing?")
    end

    before do
      create(:searchable_resource, organization: other_organization, content_a: "Light my fire")
    end

    it "returns resources only from current_organization" do
      described_class.call(term, current_organization) do
        on(:ok) do |results_by_type|
          results = results_by_type["Decidim::DummyResources::DummyResource"]
          expect(results[:count]).to eq(1)
          expect(results[:results].first).to eq(result.resource)
        end
        on(:invalid) { raise("Should not happen") }
      end
    end

    it "only returns searchable results" do
      expect(Decidim::Searchable.searchable_resources).not_to have_key(fake_type)
      described_class.call(term, current_organization, "with_resource_type" => "") do
        on(:ok) do |results_by_type|
          expect(results_by_type).not_to have_key(fake_type)
        end
        on(:invalid) { raise("Should not happen") }
      end
    end
  end

  context "with resources indexed in many languages" do
    let!(:lice_ca) { create(:searchable_resource, organization: current_organization, locale: :ca, content_a: "Erradicació de polls a l'escola") }
    let!(:lice_en) { create(:searchable_resource, organization: current_organization, locale: :en, content_a: "Eradication of lice in school") }
    let!(:ci_ca) { create(:searchable_resource, organization: current_organization, locale: :ca, content_a: "Millora continua mitjançant enquestes periòdiques") }
    let!(:ci_en) { create(:searchable_resource, organization: current_organization, locale: :en, content_a: "Continous improvement with periodic polls") }

    context "when term has matches in many languages" do
      let(:term) { "polls" }
      let(:locale_before) { I18n.locale }

      it "returns only results in current language" do
        I18n.with_locale(:ca) do
          described_class.call(term, current_organization) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results]).to eq([lice_ca.resource])
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end
  end

  context "when Search is empty" do
    let(:term) { "whatever" }

    it "returns an empty list" do
      described_class.call(term, current_organization) do
        on(:ok) do |results_by_type|
          results = results_by_type["Decidim::DummyResources::DummyResource"]
          expect(results[:results]).to be_empty
        end
        on(:invalid) { raise("Should not happen") }
      end
    end
  end

  context "when 'term' param is empty" do
    let(:term) { "" }

    before do
      create(:searchable_resource, organization: current_organization)
    end

    it "returns some random results" do
      described_class.call(term, current_organization) do
        on(:ok) do |results_by_type|
          results = results_by_type["Decidim::DummyResources::DummyResource"]
          expect(results[:results]).not_to be_empty
        end
        on(:invalid) { raise("Should not happen") }
      end
    end
  end

  describe "when search term has imperfections" do
    # NOTE: when indexing searchables accents are removed
    let!(:searchable1) { create(:searchable_resource, organization: current_organization, locale: I18n.locale, content_a: "Sangtrait és un gran grup") }
    let!(:searchable2) { create(:searchable_resource, organization: current_organization, locale: I18n.locale, content_a: "A mi m'agrada Sangtrait") }

    context "with accents in the term" do
      let(:term) { "sangtraït" }

      it "returns all matches ignoring accents" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::DummyResources::DummyResource"]
            expect(results[:count]).to eq(2)
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "with up and down cased letters in the term" do
      let(:term) { "sAnGtRaït" }

      it "returns all matches ignoring letter case" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::DummyResources::DummyResource"]
            expect(results[:count]).to eq(2)
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end
  end

  describe "ordering" do
    let!(:searchable1) { create(:searchable_resource, organization: current_organization, locale: I18n.locale, content_a: "Black Sabbat yeah", datetime: datetime1) }
    let!(:searchable2) { create(:searchable_resource, organization: current_organization, locale: I18n.locale, content_a: "Back in black també yeah", datetime: datetime2) }
    let(:term) { "black" }

    context "when searchables are from the future" do
      let(:datetime1) { 10.seconds.from_now }
      let(:datetime2) { 20.seconds.from_now }

      it "returns matches sorted by date descendently" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::DummyResources::DummyResource"]
            expect(results[:results]).to eq [searchable2.resource, searchable1.resource]
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when searchables are from the past" do
      let(:datetime1) { 1.day.ago }
      let(:datetime2) { 2.days.ago }

      it "returns matches sorted by date descendently" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::DummyResources::DummyResource"]
            expect(results[:results]).to eq [searchable1.resource, searchable2.resource]
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when searchables are from the future and the past" do
      let(:datetime1) { 1.day.from_now }
      let(:datetime2) { 1.day.ago }

      it "returns matches sorted by date descendently" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::DummyResources::DummyResource"]
            expect(results[:results]).to eq [searchable1.resource, searchable2.resource]
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end
  end

  describe "when filtering" do
    let(:term) { "king nothing" }
    let(:scope) { create(:scope, organization: current_organization) }

    context "with resource type" do
      let(:resource_type) { "Decidim::DummyResources::DummyResource" }

      before do
        create_list(:searchable_resource, 5, organization: current_organization, resource_type: resource_type, content_a: "Where's your crown king nothing?")

        # rubocop:disable RSpec/FactoryBot/CreateList
        3.times do
          create(
            :searchable_resource,
            organization: current_organization,
            resource: build(:user, organization: current_organization),
            scope: nil,
            decidim_participatory_space: nil,
            content_a: "Where's your crown king nothing?"
          )
        end
        # rubocop:enable RSpec/FactoryBot/CreateList
      end

      context "when resource_type is setted" do
        it "only return resources of the given type" do
          described_class.call(term, current_organization, "with_resource_type" => resource_type) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results].count).to eq 5
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 0
              expect(results[:count]).to eq 3
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "can paginate the resources" do
          described_class.call(term, current_organization, { "with_resource_type" => resource_type }, per_page: 2) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results].count).to eq 2
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 0
              expect(results[:count]).to eq 3
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when resource_type is blank" do
        it "only returns up to 4 resources of each type" do
          described_class.call(term, current_organization, "with_resource_type" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results].count).to eq 4
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 3
              expect(results[:count]).to eq 3
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "ignores pagination" do
          described_class.call(term, current_organization, { "with_resource_type" => "" }, per_page: 2) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results].count).to eq 4
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 3
              expect(results[:count]).to eq 3
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    context "with scope" do
      let!(:scoped_resource) do
        create(:searchable_resource, organization: current_organization, scope: scope, content_a: "Where's your crown king nothing?")
      end

      before do
        create(:searchable_resource, organization: current_organization, content_a: "Where's your crown king nothing?")
      end

      context "when scope is setted" do
        it "only return resources in the given scope" do
          described_class.call(term, current_organization, "decidim_scope_id_eq" => scope.id.to_s) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [scoped_resource.resource]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when scope is blank" do
        it "does not apply scope filter" do
          described_class.call(term, current_organization, "decidim_scope_id_eq" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:results]).not_to be_empty
              expect(results[:count]).to eq 2
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end

    describe "with space state" do
      let!(:active) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where's your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :active, organization: current_organization)
        )
      end
      let!(:past) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where's your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :past, organization: current_organization)
        )
      end
      let!(:future) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where's your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :upcoming, organization: current_organization)
        )
      end

      describe "when selecting active spaces" do
        it "returns data from active spaces" do
          described_class.call(term, current_organization, "with_space_state" => "active") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [active.resource]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      describe "when selecting future spaces" do
        it "returns data from future spaces" do
          described_class.call(term, current_organization, "with_space_state" => "future") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [future.resource]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      describe "when selecting past spaces" do
        it "returns data from past spaces" do
          described_class.call(term, current_organization, "with_space_state" => "past") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:count]).to eq 1
              expect(results[:results]).to eq [past.resource]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      describe "when no state is selected" do
        it "returns data from all spaces" do
          described_class.call(term, current_organization, "with_space_state" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::DummyResources::DummyResource"]
              expect(results[:count]).to eq 3
              expect(results[:results]).to match_array [active.resource, past.resource, future.resource]
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end
  end
end
