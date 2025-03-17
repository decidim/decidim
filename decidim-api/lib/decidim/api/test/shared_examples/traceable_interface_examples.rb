# frozen_string_literal: true

require "spec_helper"

shared_examples_for "traceable interface" do
  let(:field) { :title }

  describe "traceable", versioning: true do
    let(:version_author) { try(:author) || model.try(:creator_identity) || model.try(:normalized_author) }

    before { Decidim.traceability.update!(model, version_author, field => { en: "test" }) }

    context "when field createdAt" do
      let(:query) { "{ versions { createdAt } }" }

      it "returns created_at field of the version to iso format" do
        dates = response["versions"].map { |version| version["createdAt"] }
        expect(dates).to include(*model.versions.map { |version| version.created_at.to_time.iso8601 })
      end
    end

    context "when field id" do
      let(:query) { "{ versions { id } }" }

      it "returns ID field of the version" do
        ids = response["versions"].map { |version| version["id"].to_i }
        expect(ids).to include(*model.versions.map(&:id))
      end
    end

    context "when field editor" do
      let(:query) { "{ versions { editor { name } } }" }

      it "returns editor field of the versions" do
        editors = response["versions"].map { |version| version["editor"]["name"] if version["editor"] }
        expect(editors).to include(*model.versions.map { |version| version.editor.name if version.respond_to? :editor })
      end
    end

    context "when field changeset" do
      let(:query) { "{ versions { changeset } }" }

      it "returns changeset field of the versions" do
        changesets = response["versions"].map { |version| version["changeset"] }
        expect(changesets).to include(*model.versions.map(&:changeset))
      end
    end
  end
end
