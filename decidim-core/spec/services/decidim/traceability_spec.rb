# frozen_string_literal: true

require "spec_helper"

describe Decidim::Traceability, versioning: true do
  subject { described_class.new }

  let!(:organization) { dummy_resource.organization }
  let!(:user) { create :user, organization: }
  let(:klass) { Decidim::DummyResources::DummyResource }
  let(:params) { attributes_for(:dummy_resource, scope: nil) }
  let(:dummy_resource) { create :dummy_resource }

  describe "create" do
    it "calls `create` to the class" do
      expect(klass).to receive(:create).with(params).and_call_original
      subject.create(klass, user, params)
    end

    it "generates a new version for the resource" do
      resource = subject.create(klass, user, params)
      expect(resource.versions.count).to eq 1
      expect(resource.versions.last.event).to eq "create"
    end

    it "sets the author of the version to the user" do
      resource = subject.create(klass, user, params)
      expect(resource.versions.last.whodunnit).to eq user.to_gid.to_s
    end

    it "logs the action" do
      expect(Decidim::ActionLogger)
        .to receive(:log)
        .with(:create, user, a_kind_of(klass), kind_of(Integer), kind_of(Hash))
      subject.create(klass, user, params)
    end

    context "when the created record is not valid" do
      it "does not log the action" do
        allow(klass).to receive(:create).with(params).and_return(dummy_resource)
        allow(dummy_resource).to receive(:valid?).and_return(false)

        expect(Decidim::ActionLogger).not_to receive(:log)
        subject.create(klass, user, params)
      end
    end
  end

  describe "create!" do
    it "calls `create!` to the class" do
      expect(klass).to receive(:create!).with(params).and_call_original
      subject.create!(klass, user, params)
    end

    it "generates a new version for the resource" do
      resource = subject.create!(klass, user, params)
      expect(resource.versions.count).to eq 1
      expect(resource.versions.last.event).to eq "create"
    end

    it "sets the author of the version to the user" do
      resource = subject.create!(klass, user, params)
      expect(resource.versions.last.whodunnit).to eq user.to_gid.to_s
    end

    it "logs the action" do
      expect(Decidim::ActionLogger)
        .to receive(:log)
        .with(:create, user, a_kind_of(klass), a_kind_of(Integer), a_kind_of(Hash))
      subject.create!(klass, user, params)
    end

    context "when the created record is not valid" do
      it "does not log the action" do
        allow(klass).to receive(:create!).with(params).and_return(dummy_resource)
        allow(dummy_resource).to receive(:valid?).and_return(false)

        expect(Decidim::ActionLogger).not_to receive(:log)
        subject.create!(klass, user, params)
      end
    end
  end

  describe "update!" do
    it "calls `update!` to the resource" do
      expect(dummy_resource).to receive(:update!).with(params)
      subject.update!(dummy_resource, user, params)
    end

    it "generates a new version for the resource" do
      resource = subject.update!(dummy_resource, user, params)
      expect(resource.versions.count).to eq 2
      expect(resource.versions.last.event).to eq "update"
    end

    it "sets the author of the version to the user" do
      resource = subject.update!(dummy_resource, user, params)
      expect(resource.versions.last.whodunnit).to eq user.to_gid.to_s
    end

    it "logs the action" do
      expect(Decidim::ActionLogger)
        .to receive(:log)
        .with(:update, user, dummy_resource, a_kind_of(Integer), a_kind_of(Hash))
      subject.update!(dummy_resource, user, params)
    end
  end

  describe "version_editor" do
    context "when editor is a string" do
      let(:author) { "the_author_name" }

      it "returns the string" do
        resource = subject.update!(dummy_resource, author, params)
        editor = subject.version_editor(resource.versions.last)
        expect(editor).to eq author
      end
    end

    context "when editor is an object" do
      let(:author) { user }

      it "returns the string" do
        resource = subject.update!(dummy_resource, author, params)
        editor = subject.version_editor(resource.versions.last)
        expect(editor).to eq author
      end
    end
  end

  describe "last_editor" do
    it "finds the editor of the last version" do
      resource = subject.update!(dummy_resource, user, title: { en: "New title" })
      resource = subject.update!(resource, "my user name", title: { en: "Another title" })
      editor = subject.last_editor(resource)

      expect(editor).to eq "my user name"
    end
  end
end
