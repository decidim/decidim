# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Admin::VotingForm do
  subject { described_class.from_params(attributes).with_context(current_organization: organization) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:scope) { create :scope, organization: }

  let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }
  let(:slug) { "voting-slug" }
  let(:start_time) { 1.day.from_now }
  let(:end_time) { start_time + 1.month }
  let(:promoted) { true }
  let(:banner_image) { upload_test_file(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")) }
  let(:voting_type) { "online" }
  let(:census_contact_information) { nil }

  let(:attributes) do
    {
      voting: {
        title:,
        description:,
        slug:,
        start_time:,
        end_time:,
        scope_id: scope&.id,
        banner_image:,
        promoted:,
        voting_type:,
        census_contact_information:
      }
    }
  end

  it { is_expected.to be_valid }

  describe "when default language in title is missing" do
    let(:title) { { ca: "Títol" } }

    it { is_expected.to be_invalid }
  end

  describe "when default language in description is missing" do
    let(:description) { { ca: "Descripció" } }

    it { is_expected.to be_invalid }
  end

  describe "when slug is missing" do
    let(:slug) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when slug is not valid" do
    let(:slug) { "2021" }

    it { is_expected.to be_invalid }
  end

  context "when slug is not unique" do
    describe "when in the same organization" do
      before do
        create(:voting, slug:, organization:)
      end

      it "is not valid" do
        expect(subject).to be_invalid
        expect(subject.errors[:slug]).not_to be_empty
      end
    end

    describe "when in another organization" do
      before do
        create(:voting, slug:)
      end

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "when start_time is missing" do
    let(:start_time) { nil }
    let(:end_time) { 1.month.from_now }

    it { is_expected.to be_invalid }
  end

  describe "when end_time is missing" do
    let(:end_time) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when start_time is after end_time" do
    let(:start_time) { end_time + 3.days }
    let(:end_time) { 1.month.from_now }

    it { is_expected.to be_invalid }
  end

  describe "when start_time is equal to start_time" do
    let(:start_time) { end_time }
    let(:end_time) { 1.month.from_now }

    it { is_expected.to be_invalid }
  end

  describe "when scope is missing" do
    let(:scope) { nil }

    it { is_expected.to be_valid }
  end

  context "when banner_image is too big" do
    before do
      organization.settings.tap do |settings|
        settings.upload.maximum_file_size.default = 5
      end
      ActiveStorage::Blob.find_signed(banner_image).update(byte_size: 6.megabytes)
    end

    it { is_expected.not_to be_valid }
  end

  context "when images are not the expected type" do
    let(:banner_image) { upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }

    it { is_expected.not_to be_valid }
  end

  describe "when voting_type is missing" do
    let(:voting_type) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when voting_type is not in the accepted values" do
    let(:voting_type) { "invalid option" }

    it { is_expected.to be_invalid }
  end
end
