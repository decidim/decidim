# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_feature: current_feature
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:title) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:description) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:short_description) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:location) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:location_hints) do
      Decidim::Faker::Localized.sentence(3)
    end
    let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 4.hours }
    let(:scope) { create :scope, organization: organization }
    let(:scope_id) { scope.id }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:category_id) { category.id }
    let(:attributes) do
      {
        decidim_scope_id: scope_id,
        decidim_category_id: category_id,
        title_en: title[:en],
        description_en: description[:en],
        short_description_en: short_description[:en],
        location_en: location[:en],
        location_hints_en: location_hints[:en],
        address: address,
        start_time: start_time,
        end_time: end_time
      }
    end

    before do
      Geocoder::Lookup::Test.add_stub(
        address,
        [{ "latitude" => latitude, "longitude" => longitude }]
      )
    end

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when description is missing" do
      let(:description) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when location is missing" do
      let(:location) { { en: nil } }

      it { is_expected.not_to be_valid }
    end

    describe "when address is missing" do
      let(:address) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when start_time is missing" do
      let(:start_time) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when end_time is missing" do
      let(:end_time) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when current_feature is missing" do
      let(:current_feature) { nil }

      it { is_expected.not_to be_valid }
    end

    describe "when start_time is after end_time" do
      let(:start_time) { end_time + 3.days }

      it { is_expected.not_to be_valid }
    end

    describe "when end_time is before start_time" do
      let(:end_time) { start_time - 3.days }

      it { is_expected.not_to be_valid }
    end

    describe "when start_time is equal to start_time" do
      let(:start_time) { end_time }

      it { is_expected.not_to be_valid }
    end

    describe "when the scope does not exist" do
      let(:scope_id) { scope.id + 10 }

      it { is_expected.not_to be_valid }
    end

    describe "when the category does not exist" do
      let(:category_id) { category.id + 10 }

      it { is_expected.not_to be_valid }
    end

    it "validates address and store its coordinates" do
      expect(subject).to be_valid
      expect(subject.latitude).to eq(latitude)
      expect(subject.longitude).to eq(longitude)
    end

    it "properly maps category id from model" do
      meeting = create(:meeting, feature: current_feature, category: category)

      expect(described_class.from_model(meeting).decidim_category_id).to eq(category_id)
    end

    describe "scope" do
      subject { form.scope }

      context "when the scope exists" do
        it { is_expected.to be_kind_of(Decidim::Scope) }
      end

      context "when the scope does not exist" do
        let(:scope_id) { 3456 }

        it { is_expected.to eq(nil) }
      end

      context "when the scope is from another organization" do
        let(:scope_id) { create(:scope).id }

        it { is_expected.to eq(nil) }
      end

      context "when the participatory space has a scope" do
        let(:parent_scope) { create(:scope, organization: organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization, scope: parent_scope) }
        let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

        context "when the scope is descendant from participatory space scope" do
          it { is_expected.to eq(scope) }
        end

        context "when the scope is not descendant from participatory space scope" do
          let(:scope) { create(:scope, organization: organization) }

          it { is_expected.to eq(scope) }

          it "makes the form invalid" do
            expect(form).to be_invalid
          end
        end
      end
    end
  end
end
