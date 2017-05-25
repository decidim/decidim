# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "a proposal form" do
  let(:feature) { create(:proposal_feature) }
  let(:title) { "Oriol for president!" }
  let(:body) { "Everything would be better" }
  let(:author) { create(:user, organization: feature.organization) }
  let(:category) { create(:category, participatory_process: feature.participatory_process) }
  let(:scope) { create(:scope, organization: feature.organization) }
  let(:category_id) { category.try(:id) }
  let(:scope_id) { scope.try(:id) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:address) { nil }
  let(:params) do
    {
      title: title,
      body: body,
      author: author,
      category_id: category_id,
      scope_id: scope_id,
      address: address
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_feature: feature,
      current_organization: feature.organization
    )
  end

  subject { form }

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when there's no title" do
    let(:title) { nil }
    it { is_expected.to be_invalid }
  end

  context "when there's no body" do
    let(:body) { nil }
    it { is_expected.to be_invalid }
  end

  context "when no category_id" do
    let(:category_id) { nil }
    it { is_expected.to be_valid }
  end

  context "when no scope_id" do
    let(:scope_id) { nil }
    it { is_expected.to be_valid }
  end

  context "with invalid category_id" do
    let(:category_id) { 987 }
    it { is_expected.to be_invalid }
  end

  context "with invalid scope_id" do
    let(:scope_id) { 987 }
    it { is_expected.to be_invalid }
  end

  context "when geocoding is enabled" do
    let(:feature) { create(:proposal_feature, :with_geocoding_enabled) }

    context "when the address is not present" do
      it { is_expected.to be_invalid }
    end

    context "when the address is present" do
      let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

      before do
        Geocoder::Lookup::Test.add_stub(
          address,
          [{ "latitude" => latitude, "longitude" => longitude }]
        )
      end

      it "validates the address and store its coordinates" do
        expect(subject).to be_valid
        expect(subject.latitude).to eq(latitude)
        expect(subject.longitude).to eq(longitude)
      end
    end
  end

  describe "category" do
    subject { form.category }

    context "when the category exists" do
      it { is_expected.to be_kind_of(Decidim::Category) }
    end

    context "when the category does not exist" do
      let(:category_id) { 7654 }
      it { is_expected.to eq(nil) }
    end

    context "when the category is from another process" do
      let(:category_id) { create(:category).id }
      it { is_expected.to eq(nil) }
    end
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
  end
end
