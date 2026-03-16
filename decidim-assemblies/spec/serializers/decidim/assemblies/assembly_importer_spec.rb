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
          "description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "short_description" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "promoted" => false,
          "developer_group" => Decidim::Faker::Localized.sentence(word_count: 3),
          "local_area" => Decidim::Faker::Localized.sentence(word_count: 3),
          "target" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "participatory_structure" => Decidim::Faker::Localized.sentence(word_count: 3),
          "private_space" => false,
          "reference" => "ASSEMBLY-123",
          "purpose_of_action" => Decidim::Faker::Localized.sentence(word_count: 3),
          "composition" => Decidim::Faker::Localized.sentence(word_count: 3),
          "duration" => Decidim::Faker::Localized.sentence(word_count: 3),
          "creation_date" => "2022-08-01",
          "closing_date_reason" => Decidim::Faker::Localized.sentence(word_count: 3),
          "included_at" => "2022-08-01",
          "closing_date" => "2023-08-01",
          "created_by_other" => Decidim::Faker::Localized.sentence(word_count: 3),
          "internal_organisation" => Decidim::Faker::Localized.sentence(word_count: 3),
          "is_transparent" => true,
          "special_features" => Decidim::Faker::Localized.sentence(word_count: 3),
          "twitter_handler" => "@assembly",
          "instagram_handler" => "@assembly",
          "facebook_handler" => "assembly",
          "youtube_handler" => "assembly",
          "github_handler" => "assembly",
          "created_by" => "citizens",
          "meta_scope" => Decidim::Faker::Localized.sentence(word_count: 3),
          "announcement" => Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
          "remote_hero_image_url" => hero_image_url
        }
      end
      let(:hero_image_url) { nil }

      it "imports the assembly correctly" do
        expect { subject }.to change(Decidim::Assembly, :count).by(1)

        expect(subject.title).to eq(options[:title])
        expect(subject.slug).to eq(options[:slug])
        expect(subject.subtitle).to eq(import_data["subtitle"])
        expect(subject.description).to eq(import_data["description"])
        expect(subject.short_description).to eq(import_data["short_description"])
      end

      context "when hero image URL is present and accessible" do
        let(:hero_image_url) { "http://example.com/hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 200, body: File.read(Decidim::Dev.asset("city.jpeg")))
          stub_request(:head, hero_image_url)
            .to_return(status: 200, headers: { "Content-Type" => "image/jpeg" })
        end

        it "imports the assembly with the hero image" do
          expect { subject }.to change(Decidim::Assembly, :count).by(1)
          expect(subject.hero_image).to be_attached
        end

        it "has no warnings" do
          subject
          expect(importer.warnings).to be_empty
        end
      end

      context "when hero image URL returns 404 error" do
        let(:hero_image_url) { "http://example.com/missing-hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 404, body: "Not Found")
          stub_request(:head, hero_image_url)
            .to_return(status: 404, body: "Not Found")
        end

        it "imports the assembly successfully" do
          expect { subject }.to change(Decidim::Assembly, :count).by(1)
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
        let(:hero_image_url) { "http://example.com/server-error-hero.jpg" }

        before do
          stub_request(:get, hero_image_url)
            .to_return(status: 500, body: "Internal Server Error")
          stub_request(:head, hero_image_url)
            .to_return(status: 500, body: "Internal Server Error")
        end

        it "imports the assembly successfully" do
          expect { subject }.to change(Decidim::Assembly, :count).by(1)
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
        let(:hero_image_url) { nil }

        it "imports the assembly without images and no warnings" do
          expect { subject }.to change(Decidim::Assembly, :count).by(1)
          expect(subject.hero_image).not_to be_attached
          expect(importer.warnings).to be_empty
        end
      end

      context "when image URL is empty string" do
        let(:hero_image_url) { "" }

        it "imports the assembly without images and no warnings" do
          expect { subject }.to change(Decidim::Assembly, :count).by(1)
          expect(subject.hero_image).not_to be_attached
          expect(importer.warnings).to be_empty
        end
      end
    end

    describe "#import_folders_and_attachments" do
      let(:assembly) { create(:assembly, organization:) }
      let(:importer) { described_class.new(organization, user) }

      before do
        importer.instance_variable_set(:@imported_assembly, assembly)
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

          it "attaches the file to the assembly" do
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

          it "attaches the file to the assembly" do
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
      end
    end
  end
end
