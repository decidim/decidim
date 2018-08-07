# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Search do
    describe "call" do
      let(:current_organization) { create(:organization) }

      context "with resources from different organizations" do
        let(:other_organization) { create(:organization) }
        let(:term) { "fire" }

        before do
          create(:searchable_resource, organization: current_organization, content_a: "Fight fire with fire")
          create(:searchable_resource, organization: other_organization, content_a: "Light my fire")
        end

        it "returns resources only from current_organization" do
          described_class.call(term, current_organization) do
            on(:ok) do |results|
              expect(results.count).to eq(1)
              expect(results.first.organization).to eq(current_organization)
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
                on(:ok) do |results|
                  expect(results.pluck(:id)).to eq([lice_ca.id])
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
            on(:ok) do |results|
              expect(results).to be_empty
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
            on(:ok) do |results|
              expect(results).not_to be_empty
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
              on(:ok) do |results|
                expect(results.count).to eq(2)
              end
              on(:invalid) { raise("Should not happen") }
            end
          end
        end

        context "with up and down cased letters in the term" do
          let(:term) { "sAnGtRaït" }

          it "returns all matches ignoring letter case" do
            described_class.call(term, current_organization) do
              on(:ok) do |results|
                expect(results.count).to eq(2)
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
          let(:datetime1) { Time.current + 10.seconds }
          let(:datetime2) { Time.current + 20.seconds }

          it "returns matches sorted by date descendently" do
            described_class.call(term, current_organization) do
              on(:ok) do |results|
                expected_list = [[searchable2.id, datetime2], [searchable1.id, datetime1]]
                expected_list.zip(results.pluck(:id, :datetime)).each do |expected, current|
                  expect([expected.first, expected.last.to_s(:short)]).to eq([current.first, current.last.to_s(:short)])
                end
              end
              on(:invalid) { raise("Should not happen") }
            end
          end
        end

        context "when searchables are from the past" do
          let(:datetime1) { Time.current - 1.day }
          let(:datetime2) { Time.current - 2.days }

          it "returns matches sorted by date descendently" do
            described_class.call(term, current_organization) do
              on(:ok) do |results|
                [datetime1, datetime2].zip(results.pluck(:datetime)).each do |expected, current|
                  expect(expected.to_s(:short)).to eq(current.to_s(:short))
                end
              end
              on(:invalid) { raise("Should not happen") }
            end
          end
        end

        context "when searchables are from the future and the past" do
          let(:datetime1) { Time.current + 1.day }
          let(:datetime2) { Time.current - 1.day }

          it "returns matches sorted by date descendently" do
            described_class.call(term, current_organization) do
              on(:ok) do |results|
                [datetime1, datetime2].zip(results.pluck(:datetime)).each do |expected, current|
                  expect(expected.to_s(:short)).to eq(current.to_s(:short))
                end
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
          let(:resource_type) { "Decidim::Meetings::Meeting" }

          before do
            create(:searchable_resource, organization: current_organization, resource_type: resource_type, content_a: "Where's your crown king nothing?")
            create(:searchable_resource, organization: current_organization, resource_type: "Decidim::Proposals::Proposal", content_a: "Where's your crown king nothing?")
          end

          context "when resource_type is setted" do
            it "only return resources of the given type" do
              described_class.call(term, current_organization, "resource_type" => resource_type) do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(
                    results.all? { |r| r.resource_type == resource_type }
                  ).to be true
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end

          context "when resource_type is blank" do
            it "does not apply resource_type filter" do
              described_class.call(term, current_organization, "resource_type" => "") do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(results.count).to eq 2
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end
        end

        context "with scope" do
          before do
            create(:searchable_resource, organization: current_organization, scope: scope, content_a: "Where's your crown king nothing?")
            create(:searchable_resource, organization: current_organization, content_a: "Where's your crown king nothing?")
          end

          context "when scope is setted" do
            it "only return resources in the given scope" do
              described_class.call(term, current_organization, "decidim_scope_id" => scope.id.to_s) do
                on(:ok) do |results|
                  expect(results.count).to eq 1
                  expect(
                    results.all? { |r| r.decidim_scope_id == scope.id }
                  ).to be true
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end

          context "when scope is blank" do
            it "does not apply scope filter" do
              described_class.call(term, current_organization, "decidim_scope_id" => "") do
                on(:ok) do |results|
                  expect(results).not_to be_empty
                  expect(results.count).to eq 2
                end
                on(:invalid) { raise("Should not happen") }
              end
            end
          end
        end
      end
    end
  end
end
