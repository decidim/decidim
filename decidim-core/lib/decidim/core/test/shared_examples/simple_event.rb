# frozen_string_literal: true

require "spec_helper"

shared_context "when a simple event" do
  subject do
    described_class.new(
      resource: resource,
      event_name: event_name,
      user: user,
      extra: extra
    )
  end

  let(:organization) do
    if resource.respond_to?(:organization)
      resource.organization
    else
      create :organization
    end
  end
  let(:user) { create :user, organization: organization }
  let(:extra) { {} }
  let(:resource_path) { resource_locator(resource).path }
  let(:resource_url) { resource_locator(resource).url }
  let(:resource_title) { resource.title["en"] }
  let(:participatory_space) { resource.participatory_space }
  let(:participatory_space_title) { participatory_space.title["en"] }
  let(:participatory_space_path) { Decidim::ResourceLocatorPresenter.new(participatory_space).path }
  let(:participatory_space_url) { Decidim::ResourceLocatorPresenter.new(participatory_space).url }
  let(:author) { resource.author }
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:i18n_scope) { event_name }
end

shared_examples_for "a simple event" do |skip_space_checks|
  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to be_kind_of(String)
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to be_kind_of(String)
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to be_kind_of(String)
    end
  end

  describe "email_greeting" do
    it "is generated correctly" do
      expect(subject.email_greeting).to be_kind_of(String)
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to be_kind_of(String)
    end
  end

  describe "resource_path" do
    it "is generated correctly" do
      expect(subject.resource_path).to be_kind_of(String)
    end
  end

  describe "resource_url" do
    it "is generated correctly" do
      expect(subject.resource_url).to be_kind_of(String)
      expect(subject.resource_url).to start_with("http")
    end
  end

  unless skip_space_checks
    describe "participatory_space_url" do
      it "is generated correctly" do
        expect(subject.participatory_space_url).to be_kind_of(String)
        expect(subject.participatory_space_url).to start_with("http")
      end
    end
  end

  describe "i18n_options" do
    subject { super().i18n_options }

    it { is_expected.to include(resource_path: satisfy(&:present?)) }
    it { is_expected.to include(resource_title: satisfy(&:present?)) }
    it { is_expected.to include(resource_url: start_with("http")) }
    it { is_expected.to include(scope: i18n_scope) }

    unless skip_space_checks
      it { is_expected.to include(participatory_space_title: satisfy(&:present?)) }
      it { is_expected.to include(participatory_space_url: start_with("http")) }
    end
  end
end
