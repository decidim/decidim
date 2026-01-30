# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe AssemblyImporter do
    subject { importer }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, :admin, organization:) }
    let(:importer) { described_class.new(organization, user) }

    describe "#import" do
      subject { importer.import(import_data, user, options) }

      let(:options) do
        {
          title: generate_localized_title,
          slug: "imported"
        }
      end
      let(:import_data) do
        {
          "subtitle" => Decidim::Faker::Localized.sentence(word_count: 3),
          "short_description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "promoted" => false,
          "developer_group" => Decidim::Faker::Localized.sentence(word_count: 3),
          "local_area" => Decidim::Faker::Localized.sentence(word_count: 3),
          "target" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_structure" => Decidim::Faker::Localized.sentence(word_count: 3),
          "meta_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "reference" => "ASSEMBLY-REF-001",
          "purpose_of_action" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "composition" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "duration" => "2022-08-01",
          "creation_date" => "2022-07-01",
          "closing_date" => "2023-08-01",
          "closing_date_reason" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "included_at" => "2022-07-15",
          "created_by_other" => Decidim::Faker::Localized.sentence(word_count: 2),
          "created_by" => "others",
          "internal_organisation" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "special_features" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "twitter_handler" => "assembly_twitter",
          "instagram_handler" => "assembly_instagram",
          "facebook_handler" => "assembly_facebook",
          "youtube_handler" => "assembly_youtube",
          "github_handler" => "assembly_github",
          "announcement" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "access_mode" => "open"
        }
      end

      it "imports the assembly correctly" do
        expect { subject }.to change(Decidim::Assembly, :count).by(1)

        expect(subject.title).to eq(options[:title])
        expect(subject.slug).to eq(options[:slug])
        expect(subject.subtitle).to eq(import_data["subtitle"])
        expect(subject.short_description).to eq(import_data["short_description"])
        expect(subject.description).to eq(import_data["description"])
        expect(subject.promoted).to eq(import_data["promoted"])
        expect(subject.developer_group).to eq(import_data["developer_group"])
        expect(subject.local_area).to eq(import_data["local_area"])
        expect(subject.target).to eq(import_data["target"])
        expect(subject.participatory_scope).to eq(import_data["participatory_scope"])
        expect(subject.participatory_structure).to eq(import_data["participatory_structure"])
        expect(subject.meta_scope).to eq(import_data["meta_scope"])
        expect(subject.reference).to eq(import_data["reference"])
        expect(subject.purpose_of_action).to eq(import_data["purpose_of_action"])
        expect(subject.composition).to eq(import_data["composition"])
        expect(subject.duration).to eq(Date.parse(import_data["duration"]))
        expect(subject.creation_date).to eq(Date.parse(import_data["creation_date"]))
        expect(subject.closing_date).to eq(Date.parse(import_data["closing_date"]))
        expect(subject.closing_date_reason).to eq(import_data["closing_date_reason"])
        expect(subject.included_at).to eq(Date.parse(import_data["included_at"]))
        expect(subject.created_by_other).to eq(import_data["created_by_other"])
        expect(subject.created_by).to eq(import_data["created_by"])
        expect(subject.internal_organisation).to eq(import_data["internal_organisation"])
        expect(subject.special_features).to eq(import_data["special_features"])
        expect(subject.twitter_handler).to eq(import_data["twitter_handler"])
        expect(subject.instagram_handler).to eq(import_data["instagram_handler"])
        expect(subject.facebook_handler).to eq(import_data["facebook_handler"])
        expect(subject.youtube_handler).to eq(import_data["youtube_handler"])
        expect(subject.github_handler).to eq(import_data["github_handler"])
        expect(subject.announcement).to eq(import_data["announcement"])
        expect(subject.access_mode).to eq(import_data["access_mode"])
      end

      context "when handling legacy access fields" do
        context "with private_space true" do
          let(:import_data) do
            super().merge("access_mode" => nil, "private_space" => true)
          end

          it "maps to restricted access mode" do
            expect(subject.access_mode).to eq("restricted")
          end
        end

        context "with is_transparent true" do
          let(:import_data) do
            super().merge("access_mode" => nil, "is_transparent" => true)
          end

          it "maps to transparent access mode" do
            expect(subject.access_mode).to eq("transparent")
          end
        end

        context "with both legacy fields set" do
          let(:import_data) do
            super().merge("access_mode" => nil, "private_space" => true, "is_transparent" => true)
          end

          it "prioritizes access_mode to transparent" do
            expect(subject.access_mode).to eq("transparent")
          end
        end

        context "with no access mode fields" do
          let(:import_data) do
            super().merge("access_mode" => nil, "private_space" => false, "is_transparent" => false)
          end

          it "defaults to open access mode" do
            expect(subject.access_mode).to eq("open")
          end
        end

        context "with modern access_mode present" do
          let(:import_data) do
            super().merge("access_mode" => "restricted", "private_space" => false)
          end

          it "uses the modern access_mode field" do
            expect(subject.access_mode).to eq("restricted")
          end
        end
      end
    end
  end
end
