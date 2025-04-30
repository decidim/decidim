# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Document do
      subject { document }

      let(:document) { build(:collaborative_text_document, :with_versions) }
      let(:organization) { document.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }

      include_examples "has component"
      include_examples "resourceable"

      context "without a title" do
        let(:document) { build(:collaborative_text_document, title: nil) }

        it { is_expected.not_to be_valid }
      end

      context "without a body" do
        let(:document) { build(:collaborative_text_document, body: nil) }

        it { is_expected.not_to be_valid }
      end

      it "has a versions" do
        expect(document.document_versions).to all(be_a(Decidim::CollaborativeTexts::Version))
      end

      it "current version points to last created" do
        document.save!
        version = create(:collaborative_text_version, created_at: 1.second.from_now, document: document)
        expect(document.reload.document_versions.count).to eq(4)
        expect(document.current_version).to eq(version)
      end

      context "without a version" do
        let(:document) { build(:collaborative_text_document, body: "A body test") }

        it "creates a version" do
          expect { document.save! }.to change { document.document_versions.count }.by(1)
          expect(document.body).to eq("A body test")
        end
      end

      context "when document exists" do
        let(:document) { create(:collaborative_text_document, :with_body) }

        it "returns the body of the current version" do
          expect(document.body).to eq(document.current_version.body)
          expect(document.document_versions.count).to eq(1)
        end

        it "updates the body of the current version" do
          document.body = "New body"
          document.save!
          expect(document.body).to eq("New body")
          expect(document.current_version.body).to eq("New body")
          expect(document.document_versions.reload.count).to eq(1)
        end

        context "when versions exists" do
          let(:document) { create(:collaborative_text_document, document_versions:) }
          let(:version1) { build(:collaborative_text_version, body: "Version 1", document: nil, created_at: 3.minutes.ago) }
          let(:version2) { build(:collaborative_text_version, body: "Version 2", document: nil, created_at: 2.minutes.ago) }
          let(:version3) { build(:collaborative_text_version, :draft, body: "Version 3", document: nil, created_at: 1.minute.ago) }
          let(:document_versions) { [version1, version2, version3] }

          it "returns the body of the current version" do
            expect(document.body).to eq(version3.body)
            expect(document.document_versions.count).to eq(3)
            expect(document.document_versions.consolidated.count).to eq(2)
            expect(document.consolidated_version).to eq(version2)
          end

          context "when destroying" do
            it "is soft-deleted and restored with the versions" do
              document.destroy
              expect(Decidim::CollaborativeTexts::Document.all).to be_empty
              expect(Decidim::CollaborativeTexts::Document.only_deleted.first).to eq(document)
              expect(Decidim::CollaborativeTexts::Version.all).to be_empty
              expect(Decidim::CollaborativeTexts::Version.only_deleted.count).to eq(3)
              document.restore
              expect(Decidim::CollaborativeTexts::Document.all).to eq([document])
              expect(Decidim::CollaborativeTexts::Document.only_deleted).to be_empty
              expect(Decidim::CollaborativeTexts::Version.all).to eq(document_versions)
              expect(Decidim::CollaborativeTexts::Version.only_deleted).to be_empty
            end
          end
        end
      end

      context "when creating a new version" do
        let(:document) { create(:collaborative_text_document, body: "My first version") }

        it "creates a new version" do
          expect(document.document_versions.count).to eq(1)
          expect(document.body).to eq("My first version")

          expect { document.document_versions.create(body: "My first amended version", draft: true) }.to change { document.document_versions.count }.by(1)
          expect(document.body).to eq("My first amended version")
          expect(document.consolidated_body).to eq("My first version")
          expect(document.document_versions.count).to eq(2)

          expect { document.document_versions.last.update(body: "My second version") }.not_to(change { document.document_versions.count })
          expect(document.body).to eq("My second version")
          expect(document.consolidated_body).to eq("My first version")
          expect(document.document_versions.count).to eq(2)

          expect { document.document_versions.last.update(draft: false) }.not_to(change { document.document_versions.count })
          expect(document.body).to eq("My second version")
          expect(document.consolidated_body).to eq("My second version")
          expect(document.document_versions.count).to eq(2)
        end
      end
    end
  end
end
