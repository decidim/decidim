# frozen_string_literal: true

require "spec_helper"

describe Decidim::Traceability, versioning: true do
  let!(:user) { create :user }
  let(:klass) { Decidim::DummyResources::DummyResource }
  let(:params) { attributes_for(:dummy_resource) }
  subject { described_class.new }

  describe "create" do
    it "calls `create` to the class" do
      expect(klass).to receive(:create).with(params)
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
  end

  describe "create!" do
    it "calls `create!` to the class" do
      expect(klass).to receive(:create!).with(params)
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
  end

  describe "update!" do
    let(:dummy_resource) { create :dummy_resource }

    it "calls `update_attributes!` to the resource" do
      expect(dummy_resource).to receive(:update_attributes!).with(params)
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
  end
end
