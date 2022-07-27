# frozen_string_literal: true

require "spec_helper"

shared_context "when a simple event" do
  include Decidim::SanitizeHelper
  subject { event_instance }

  let(:event_instance) do
    described_class.new(
      resource:,
      event_name:,
      user:,
      user_role:,
      extra:
    )
  end

  let(:organization) do
    if resource.respond_to?(:organization)
      resource.organization
    else
      create :organization
    end
  end
  let(:user) { create :user, organization: }
  let(:user_role) { :follower }
  let(:extra) { {} }
  let(:resource_path) { resource_locator(resource).path }
  let(:resource_url) { resource_locator(resource).url }
  let(:resource_title) { resource.title["en"] }
  # to be used when resource is a component resource, not a participatory space, in which case should be overriden
  let(:participatory_space) { resource.participatory_space }
  let(:participatory_space_title) { participatory_space.title["en"] }
  let(:participatory_space_path) { Decidim::ResourceLocatorPresenter.new(participatory_space).path }
  let(:participatory_space_url) { Decidim::ResourceLocatorPresenter.new(participatory_space).url }
  let(:author) do
    if resource.respond_to?(:creator_author)
      resource.creator_author
    else
      resource.author
    end
  end
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:author_name) { decidim_html_escape author.name }
  let(:author_path) { author_presenter&.profile_path.to_s }
  let(:author_nickname) { author_presenter&.nickname.to_s }
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
      expect(subject.email_subject).not_to include("translation missing")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to be_kind_of(String)
      expect(subject.email_intro).not_to include("translation missing")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro).to be_kind_of(String)
      expect(subject.email_outro).not_to include("translation missing")
    end
  end

  describe "email_greeting" do
    it "is generated correctly" do
      expect(subject.email_greeting).to be_kind_of(String)
      expect(subject.email_greeting).not_to include("translation missing")
    end
  end

  describe "safe_resource_text" do
    it "is generated correctly" do
      expect(subject.safe_resource_text).to be_kind_of(String)
      expect(subject.safe_resource_text).to be_html_safe
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title).to be_kind_of(String)
      expect(subject.notification_title).not_to include("translation missing")
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

  describe "resource_title" do
    it "responds to the method" do
      expect(subject).to respond_to(:resource_title)
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

    it "includes the i18n scope" do
      if event_instance.event_has_roles?
        expect(subject).to include(scope: "#{i18n_scope}.#{user_role}")
      else
        expect(subject).to include(scope: i18n_scope)
      end
    end

    unless skip_space_checks
      it { is_expected.to include(participatory_space_title: satisfy(&:present?)) }
      it { is_expected.to include(participatory_space_url: start_with("http")) }
    end
  end
end
