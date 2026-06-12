# frozen_string_literal: true

require "spec_helper"

describe Decidim::Search do
  let(:current_organization) { create(:organization) }

  context "with resources from different organizations" do
    let(:other_organization) { create(:organization) }
    let(:term) { "fire" }
    let(:fake_type) { "Decidim::Organization" } # a type that is not searchable
    let!(:result) do
      create(:searchable_resource, organization: current_organization, content_a: "Fight fire with fire")
    end
    let!(:non_searchable_resource) do
      create(:searchable_resource, organization: current_organization, resource_type: fake_type, content_a: "Where is your crown king nothing?")
    end

    before do
      create(:searchable_resource, organization: other_organization, content_a: "Light my fire")
    end

    it "returns resources only from current_organization" do
      described_class.call(term, current_organization) do
        on(:ok) do |results_by_type|
          results = results_by_type["Decidim::Dev::DummyResource"]
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
    let!(:ci_en) { create(:searchable_resource, organization: current_organization, locale: :en, content_a: "Continuous improvement with periodic polls") }

    context "when term has matches in many languages" do
      let(:term) { "polls" }
      let(:locale_before) { I18n.locale }

      it "returns only results in current language" do
        I18n.with_locale(:ca) do
          described_class.call(term, current_organization) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Dev::DummyResource"]
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
          results = results_by_type["Decidim::Dev::DummyResource"]
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
          results = results_by_type["Decidim::Dev::DummyResource"]
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
            results = results_by_type["Decidim::Dev::DummyResource"]
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
            results = results_by_type["Decidim::Dev::DummyResource"]
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

      it "returns matches sorted by date descendingly" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Dev::DummyResource"]
            expect(results[:results]).to eq [searchable2.resource, searchable1.resource]
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when searchables are from the past" do
      let(:datetime1) { 1.day.ago }
      let(:datetime2) { 2.days.ago }

      it "returns matches sorted by date descendingly" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Dev::DummyResource"]
            expect(results[:results]).to eq [searchable1.resource, searchable2.resource]
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when searchables are from the future and the past" do
      let(:datetime1) { 1.day.from_now }
      let(:datetime2) { 1.day.ago }

      it "returns matches sorted by date descendingly" do
        described_class.call(term, current_organization) do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Dev::DummyResource"]
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
      let(:resource_type) { "Decidim::Dev::DummyResource" }

      before do
        create_list(:searchable_resource, 5, organization: current_organization, resource_type:, content_a: "Where is your crown king nothing?")

        3.times do
          create(
            :searchable_resource,
            organization: current_organization,
            resource: build(:user, organization: current_organization),
            scope: nil,
            decidim_participatory_space: nil,
            content_a: "Where is your crown king nothing?"
          )
        end
      end

      context "when resource_type is set" do
        it "only return resources of the given type" do
          described_class.call(term, current_organization, "with_resource_type" => resource_type) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Dev::DummyResource"]
              expect(results[:results].count).to eq 5
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 0
              expect(results[:count]).to eq 0
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "can paginate the resources" do
          described_class.call(term, current_organization, { "with_resource_type" => resource_type }, per_page: 2) do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Dev::DummyResource"]
              expect(results[:results].count).to eq 2
              expect(results[:count]).to eq 5

              results = results_by_type["Decidim::User"]
              expect(results[:results].count).to eq 0
              expect(results[:count]).to eq 0
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when resource_type is blank" do
        it "only returns up to 4 resources of each type" do
          described_class.call(term, current_organization, "with_resource_type" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Dev::DummyResource"]
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
              results = results_by_type["Decidim::Dev::DummyResource"]
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

    describe "with space state" do
      let!(:active) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where is your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :active, organization: current_organization)
        )
      end
      let!(:past) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where is your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :past, organization: current_organization)
        )
      end
      let!(:future) do
        create(
          :searchable_resource,
          organization: current_organization,
          content_a: "Where is your crown king nothing?",
          decidim_participatory_space: create(:participatory_process, :upcoming, organization: current_organization)
        )
      end

      describe "when selecting active spaces" do
        it "returns data from active spaces" do
          described_class.call(term, current_organization, "with_space_state" => "active") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Dev::DummyResource"]
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
              results = results_by_type["Decidim::Dev::DummyResource"]
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
              results = results_by_type["Decidim::Dev::DummyResource"]
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
              results = results_by_type["Decidim::Dev::DummyResource"]
              expect(results[:count]).to eq 3
              expect(results[:results]).to contain_exactly(active.resource, past.resource, future.resource)
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end
  end

  describe "comments filtering" do
    let(:term) { "My Custom meeting" }
    let(:participatory_process) { create(:participatory_process, :active, organization: current_organization) }
    let(:component) { create(:dummy_component, participatory_space: participatory_process) }
    let!(:dummy_resource) { create(:dummy_resource, :published, component:, title: { en: term }) }

    let!(:comment1) { create(:comment, commentable: dummy_resource, body: { en: term }) }
    # rubocop: disable RSpec/VariableNumber
    let!(:comment1_1) { create(:comment, commentable: comment1, root_commentable: dummy_resource, body: { en: term }) }
    let!(:comment1_1_1) { create(:comment, commentable: comment1_1, root_commentable: dummy_resource, body: { en: term }) }
    # rubocop: enable RSpec/VariableNumber

    context "when comments_enabled is disabled on the component" do
      before do
        component.update!(settings: { comments_enabled: false })
      end

      it "does not return comments in search results" do
        described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Comments::Comment"]
            expect(results[:count]).to eq 0
            expect(results[:results]).to be_empty
          end
          on(:invalid) { raise("Should not happen") }
        end
      end

      it "does not return comments in general search results" do
        described_class.call(term, current_organization, "with_resource_type" => "") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Comments::Comment"]
            expect(results[:count]).to eq 0
            expect(results[:results]).to be_empty
          end
          on(:invalid) { raise("Should not happen") }
        end
      end

      it "returns the commentable resource as well" do
        described_class.call(term, current_organization, "with_resource_type" => "Decidim::Dev::DummyResource") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Dev::DummyResource"]
            expect(results[:count]).to eq 1
            expect(results[:results]).to contain_exactly(dummy_resource)
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when root_commentable is hidden" do
      before do
        create(:moderation, reportable: dummy_resource, hidden_at: 2.days.ago)
      end

      it "does not return comments in search results" do
        described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Comments::Comment"]
            expect(results[:count]).to eq 0
            expect(results[:results]).to be_empty
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when a specific comment is hidden" do
      before do
        create(:moderation, reportable: comment1_1, hidden_at: 2.days.ago)
      end

      it "returns only non-hidden comments" do
        described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Comments::Comment"]
            expect(results[:count]).to eq 2
            expect(results[:results]).to contain_exactly(comment1, comment1_1_1)
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    context "when a comment is deleted" do
      before do
        comment1_1.update!(deleted_at: 1.hour.ago)
      end

      it "returns only non-deleted comments" do
        described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
          on(:ok) do |results_by_type|
            results = results_by_type["Decidim::Comments::Comment"]
            expect(results[:count]).to eq 2
            expect(results[:results]).to contain_exactly(comment1, comment1_1_1)
          end
          on(:invalid) { raise("Should not happen") }
        end
      end
    end

    # rubocop:disable RSpec/VariableNumber
    context "when there are more comments than HIGHLIGHTED_RESULTS_COUNT" do
      let!(:comment2) { create(:comment, commentable: dummy_resource, body: { en: term }) }
      let!(:comment2_1) { create(:comment, commentable: comment2, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment2_1_1) { create(:comment, commentable: comment2_1, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment3) { create(:comment, commentable: dummy_resource, body: { en: term }) }
      let!(:comment3_1) { create(:comment, commentable: comment3, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment4) { create(:comment, commentable: dummy_resource, body: { en: term }) }
      let!(:comment4_1) { create(:comment, commentable: comment4, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment4_1_1) { create(:comment, commentable: comment4_1, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment4_1_2) { create(:comment, commentable: comment4_1, root_commentable: dummy_resource, body: { en: term }) }
      let!(:comment5) { create(:comment, commentable: dummy_resource, body: { en: term }) }
      let!(:comment5_1) { create(:comment, commentable: comment5, root_commentable: dummy_resource, body: { en: term }) }

      context "when comments_enabled is disabled on the component" do
        before do
          component.update!(settings: { comments_enabled: false })
        end

        it "returns count 0 in general search" do
          described_class.call(term, current_organization, "with_resource_type" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Comments::Comment"]
              expect(results[:count]).to eq 0
              expect(results[:results]).to be_empty
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "returns count 0 in type-filtered search" do
          described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Comments::Comment"]
              expect(results[:count]).to eq 0
              expect(results[:results]).to be_empty
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end

      context "when some comments are deleted" do
        before do
          comment4_1_1.update!(deleted_at: 1.hour.ago)
          comment5_1.update!(deleted_at: 2.hours.ago)
        end

        it "excludes deleted comments from type-filtered search count" do
          described_class.call(term, current_organization, "with_resource_type" => "Decidim::Comments::Comment") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Comments::Comment"]
              # 14 total (3 base + 11 additional) minus 2 deleted = 12
              expect(results[:count]).to eq 12
              expect(results[:results]).not_to include(comment4_1_1, comment5_1)
            end
            on(:invalid) { raise("Should not happen") }
          end
        end

        it "excludes deleted comments from general search count" do
          described_class.call(term, current_organization, "with_resource_type" => "") do
            on(:ok) do |results_by_type|
              results = results_by_type["Decidim::Comments::Comment"]
              expect(results[:count]).to eq 12
            end
            on(:invalid) { raise("Should not happen") }
          end
        end
      end
    end
    # rubocop:enable RSpec/VariableNumber
  end
end
