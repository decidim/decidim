# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe ParticipatoryProcessImporter do
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
          "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "short_description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "promoted" => false,
          "developer_group" => Decidim::Faker::Localized.sentence(word_count: 3),
          "local_area" => Decidim::Faker::Localized.sentence(word_count: 3),
          "target" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_structure" => Decidim::Faker::Localized.sentence(word_count: 3),
          "meta_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "start_date" => "2022-08-01",
          "end_date" => "2023-08-01",
          "announcement" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "private_space" => false,
          "participatory_process_group" => group_data
        }
      end
      let(:group_data) do
        {
          "title" => generate_localized_title,
          "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title }
        }
      end

      it "imports the process correctly" do
        expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)

        expect(subject.title).to eq(options[:title])
        expect(subject.slug).to eq(options[:slug])
        expect(subject.subtitle).to eq(import_data["subtitle"])
        expect(subject.description).to eq(import_data["description"])
        expect(subject.short_description).to eq(import_data["short_description"])
        expect(subject.promoted).to eq(import_data["promoted"])
        expect(subject.developer_group).to eq(import_data["developer_group"])
        expect(subject.local_area).to eq(import_data["local_area"])
        expect(subject.target).to eq(import_data["target"])
        expect(subject.participatory_scope).to eq(import_data["participatory_scope"])
        expect(subject.participatory_structure).to eq(import_data["participatory_structure"])
        expect(subject.meta_scope).to eq(import_data["meta_scope"])
        expect(subject.start_date).to eq(Date.parse(import_data["start_date"]))
        expect(subject.end_date).to eq(Date.parse(import_data["end_date"]))
        expect(subject.announcement).to eq(import_data["announcement"])
        expect(subject.private_space).to eq(import_data["private_space"])
        expect(subject.participatory_process_group).to be_a(Decidim::ParticipatoryProcessGroup)
      end

      it "imports the process group correctly" do
        expect { subject }.to change(Decidim::ParticipatoryProcessGroup, :count).by(1)

        group = subject.participatory_process_group
        expect(group.organization).to eq(subject.organization)
        expect(group.title).to eq(group_data["title"])
        expect(group.description).to eq(group_data["description"])
      end

      context "when the process group title is defined with the name key" do
        let(:group_data) do
          {
            "name" => generate_localized_title,
            "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title }
          }
        end

        it "imports the process group correctly" do
          expect { subject }.to change(Decidim::ParticipatoryProcessGroup, :count).by(1)

          group = subject.participatory_process_group
          expect(group.title).to eq(group_data["name"])
        end
      end

      context "when the process group is empty" do
        let(:group_data) do
          {
            "title" => Decidim::Faker::Localized.localized { "" },
            "description" => Decidim::Faker::Localized.localized { "" }
          }
        end

        it "does not create a process group" do
          expect { subject }.not_to change(Decidim::ParticipatoryProcessGroup, :count)
        end
      end

      context "when the process group is nil" do
        let(:group_data) do
          nil
        end

        it "imports the process correctly" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
        end
      end
    end
  end
end
