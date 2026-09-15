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
          "access_mode" => "open",
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
        expect(subject.access_mode).to eq(import_data["access_mode"])
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

      context "when handling legacy access fields" do
        context "with private_space true" do
          let(:import_data) do
            super().merge("access_mode" => nil, "private_space" => true)
          end

          it "maps to restricted access mode" do
            expect(subject.access_mode).to eq("restricted")
          end
        end

        context "with private_space true and is_transparent true" do
          let(:import_data) do
            super().merge("access_mode" => nil, "private_space" => true, "is_transparent" => true)
          end

          it "prioritizes access_mode to transparent" do
            expect(subject.access_mode).to eq("transparent")
          end
        end

        context "with private_space false and is_transparent false" do
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

      context "when hero image URL is present and accessible" do
        let(:import_data) do
          base_data.merge("remote_hero_image_url" => hero_image_url)
        end
        let(:base_data) do
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
            "private_space" => false,
            "participatory_process_group" => group_data
          }
        end
        let(:hero_image_url) { "http://example.com/hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 200, body: File.read(Decidim::Dev.asset("city.jpeg")))
          stub_request(:head, hero_image_url)
            .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })
        end

        it "imports the process with the hero image" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
          expect(subject.hero_image).to be_attached
        end

        it "has no warnings" do
          subject
          expect(importer.warnings).to be_empty
        end
      end

      context "when hero image URL returns 404 error" do
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
            "participatory_process_group" => group_data,
            "remote_hero_image_url" => hero_image_url
          }
        end
        let(:hero_image_url) { "http://example.com/missing-hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 404, body: "Not Found")
          stub_request(:head, hero_image_url)
            .to_return(status: 404, body: "Not Found")
        end

        it "imports the process successfully" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
        end

        it "does not attach the hero image" do
          subject
          expect(subject.hero_image).not_to be_attached
        end

        it "collects a warning about the missing hero image" do
          subject
          expect(importer.warnings).to include(a_string_matching(/The hero image could not be imported \(404 Not Found\)\./i))
        end
      end

      context "when hero image URL returns 500 error" do
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
            "participatory_process_group" => group_data,
            "remote_hero_image_url" => hero_image_url
          }
        end
        let(:hero_image_url) { "http://example.com/server-error-hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 500, body: "Internal Server Error")
          stub_request(:head, hero_image_url)
            .to_return(status: 500, body: "Internal Server Error")
        end

        it "imports the process successfully" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
        end

        it "does not attach the hero image" do
          subject
          expect(subject.hero_image).not_to be_attached
        end

        it "collects a warning about the hero image import failure" do
          subject
          expect(importer.warnings).to include(a_string_matching(/The hero image could not be imported \(500 Internal Server Error\)\./i))
        end
      end

      context "when image URL is nil" do
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
            "participatory_process_group" => group_data,
            "remote_hero_image_url" => nil
          }
        end

        it "imports the process without image and no warnings" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
          expect(subject.hero_image).not_to be_attached
          expect(importer.warnings).to be_empty
        end
      end

      context "when process group has a missing hero image" do
        let(:group_data) do
          {
            "title" => generate_localized_title,
            "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
            "remote_hero_image_url" => "http://example.com/missing-group-hero.jpg"
          }
        end

        before do
          stub_request(:head, "http://example.com/missing-group-hero.jpg")
            .to_return(status: 404)
          stub_request(:get, "http://example.com/missing-group-hero.jpg")
            .to_return(status: 404)
        end

        it "imports the process and group successfully" do
          expect { subject }.to change(Decidim::ParticipatoryProcess, :count).by(1)
                                                                             .and change(Decidim::ParticipatoryProcessGroup, :count).by(1)
        end

        it "does not attach the group hero image" do
          subject
          group = Decidim::ParticipatoryProcessGroup.last
          expect(group.hero_image).not_to be_attached
        end

        it "collects a warning about the missing group hero image" do
          subject
          expect(importer.warnings).to include(a_string_matching(/The hero image could not be imported \(404 Not Found\)\./i))
        end
      end
    end

    describe "#import_folders_and_attachments" do
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:importer) { described_class.new(organization, user) }

      before do
        importer.instance_variable_set(:@imported_process, participatory_process)
      end

      describe "remote file handling" do
        let(:attachments_data) do
          {
            "files" => [
              {
                "title" => { "en" => "Test File" },
                "description" => { "en" => "Test Description" },
                "weight" => 1,
                "remote_file_url" => remote_file_url
              }
            ],
            "attachment_collections" => []
          }
        end
        let(:remote_file_url) { "http://example.com/document.pdf" }

        context "when remote file is not accessible (404)" do
          before do
            stub_request(:head, remote_file_url).to_return(status: 404)
          end

          it "gracefully skips the attachment" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::Attachment, :count)
          end

          it "does not raise an error" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to raise_error
          end

          it "collects a warning about the attachment import failure" do
            importer.import_folders_and_attachments(attachments_data)
            expect(importer.warnings).to include(a_string_matching(/The attachment "Test File" could not be imported \(404 Not Found\)\./i))
          end
        end

        context "when remote file is not accessible (500)" do
          before do
            stub_request(:head, remote_file_url).to_return(status: 500)
          end

          it "gracefully skips the attachment" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::Attachment, :count)
          end

          it "does not raise an error" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to raise_error
          end

          it "collects a warning about the attachment import failure" do
            importer.import_folders_and_attachments(attachments_data)
            expect(importer.warnings).to include(a_string_matching(/The attachment "Test File" could not be imported \(500 Internal Server Error\)\./i))
          end
        end

        context "when remote file is accessible but download fails" do
          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "application/pdf" })
            stub_request(:get, remote_file_url).to_return(status: 500)
          end

          it "collects a warning about the attachment import failure" do
            importer.import_folders_and_attachments(attachments_data)
            expect(importer.warnings).to include(a_string_matching(/The attachment "Test File" could not be imported \(500 Internal Server Error\)\./i))
          end
        end

        context "when remote file is accessible and downloadable (PDF)" do
          let(:remote_file_url) { "http://example.com/document.pdf" }

          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "application/pdf" })
            stub_request(:get, remote_file_url)
              .to_return(status: 200, body: File.read(Decidim::Dev.asset("Exampledocument.pdf")))
          end

          it "successfully imports the attachment" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .to change(Decidim::Attachment, :count).by(1)
          end

          it "attaches the file to the process" do
            importer.import_folders_and_attachments(attachments_data)
            attachment = Decidim::Attachment.last
            expect(attachment.file).to be_attached
            expect(attachment.file.filename.to_s).to eq("document.pdf")
          end

          it "sets the content type automatically" do
            importer.import_folders_and_attachments(attachments_data)
            attachment = Decidim::Attachment.last
            expect(attachment.content_type).to eq("application/pdf")
          end

          it "sets the file size automatically" do
            importer.import_folders_and_attachments(attachments_data)
            attachment = Decidim::Attachment.last
            expect(attachment.file_size).to be_present
          end

          it "has no warnings" do
            importer.import_folders_and_attachments(attachments_data)
            expect(importer.warnings).to be_empty
          end
        end

        context "when remote file is accessible and downloadable (image)" do
          let(:remote_file_url) { "http://example.com/image.jpg" }

          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })
            stub_request(:get, remote_file_url)
              .to_return(status: 200, body: File.read(Decidim::Dev.asset("city.jpeg")))
          end

          it "successfully imports the attachment" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .to change(Decidim::Attachment, :count).by(1)
          end

          it "attaches the file to the process" do
            importer.import_folders_and_attachments(attachments_data)
            attachment = Decidim::Attachment.last
            expect(attachment.file).to be_attached
          end

          it "sets the content type automatically" do
            importer.import_folders_and_attachments(attachments_data)
            attachment = Decidim::Attachment.last
            expect(attachment.content_type).to eq("image/jpeg")
          end

          it "has no warnings" do
            importer.import_folders_and_attachments(attachments_data)
            expect(importer.warnings).to be_empty
          end
        end

        context "when remote file URL is blank" do
          let(:attachments_data) do
            {
              "files" => [
                {
                  "title" => { "en" => "Test File" },
                  "description" => { "en" => "Test Description" },
                  "weight" => 1,
                  "remote_file_url" => ""
                }
              ],
              "attachment_collections" => []
            }
          end

          it "does not create any attachments" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::Attachment, :count)
          end
        end

        context "when files array is nil" do
          let(:attachments_data) do
            {
              "files" => nil,
              "attachment_collections" => []
            }
          end

          it "does not create any attachments" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::Attachment, :count)
          end
        end

        context "when the attachment collection is not defined" do
          let(:attachments_data) do
            {
              "files" => [
                {
                  "title" => { "en" => "Test File" },
                  "description" => { "en" => "Test Description" },
                  "weight" => 1,
                  "remote_file_url" => remote_file_url
                }
              ]
            }
          end

          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "application/pdf" })
            stub_request(:get, remote_file_url)
              .to_return(status: 200, body: File.read(Decidim::Dev.asset("Exampledocument.pdf")))
          end

          it "does not create any attachments collections" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::AttachmentCollection, :count)
          end
        end

        context "when the attachment collection is nil" do
          let(:attachments_data) do
            {
              "files" => [
                {
                  "title" => { "en" => "Test File" },
                  "description" => { "en" => "Test Description" },
                  "weight" => 1,
                  "remote_file_url" => remote_file_url
                }
              ],
              "attachment_collections" => nil
            }
          end

          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "application/pdf" })
            stub_request(:get, remote_file_url)
              .to_return(status: 200, body: File.read(Decidim::Dev.asset("Exampledocument.pdf")))
          end

          it "does not create any attachments collections" do
            expect { importer.import_folders_and_attachments(attachments_data) }
              .not_to change(Decidim::AttachmentCollection, :count)
          end
        end

        context "when attachment collection is defined" do
          let(:attachment_data) do
            {
              "files" => [
                {
                  "title" => { "en" => "Test File" },
                  "description" => { "en" => "Test Description" },
                  "weight" => 1,
                  "remote_file_url" => remote_file_url,
                  "attachment_collections" => {
                    "name" => {
                      "en" => "Collection name"
                    },
                    "weight" => 0,
                    "description" => {
                      "en" => "Collection description"
                    }
                  }
                }
              ],
              "attachment_collections" => [
                {
                  "name" => {
                    "en" => "Collection name"
                  },
                  "weight" => 0,
                  "description" => {
                    "en" => "Collection description"
                  }
                }
              ]
            }
          end

          before do
            stub_request(:head, remote_file_url)
              .to_return(status: 200, headers: { "Content-Type" => "application/pdf" })
            stub_request(:get, remote_file_url)
              .to_return(status: 200, body: File.read(Decidim::Dev.asset("Exampledocument.pdf")))
          end

          it "creates the attachment and the collection" do
            expect { importer.import_folders_and_attachments(attachment_data) }
              .to change(Decidim::Attachment, :count).by(1)
              .and change(Decidim::AttachmentCollection, :count).by(1)
          end
        end
      end
    end
  end
end
