# frozen_string_literal: true

require "spec_helper"

describe Decidim::Registrations::UserAttributeValidator do
  subject { described_class.new(attribute: attribute, form: form) }

  let(:attribute) { "nickname" }
  let(:form) { Decidim::RegistrationForm.from_params(params).with_context(context) }
  let(:params) do
    {
      attribute => input_value
    }
  end
  let(:input_value) { "mali" }
  let(:context) do
    {
      current_organization: organization
    }
  end
  let(:user_value) { "zimbawe" }
  let(:group_value) { "africa" }
  let!(:organization) { create :organization }
  let!(:user) { create :user, :organization => organization, attribute.to_sym => user_value }
  let!(:user_group) { create :user_group, :organization => organization, attribute.to_sym => group_value }

  shared_examples "suggests alternatives" do |expectation|
    it { is_expected.not_to be_valid }

    it "suggests the word with a next consecutive number" do
      expect(subject.suggestion).to eq(expectation)
    end

    it "returns an error message" do
      expect(subject.error).to include("already been taken")
    end

    it "returns an error message with a suggestion" do
      expect(subject.error_with_suggestion).to include(subject.error)
      expect(subject.error_with_suggestion).to include(expectation)
    end
  end

  it "responds to form" do
    expect(subject.form).to eq(form)
  end

  it { is_expected.to be_valid }

  it "does not suggest an alternative word" do
    expect(subject.suggestion).to eq(input_value)
  end

  context "when attribute already belongs to a user" do
    let(:input_value) { "zimbawe" }

    it_behaves_like "suggests alternatives", "zimbawe1"

    context "and ends with numbers" do
      let(:input_value) { "zimbawe123" }
      let(:user_value) { "zimbawe123" }

      it_behaves_like "suggests alternatives", "zimbawe124"
    end
  end

  context "when attribute already belongs to a group" do
    let(:input_value) { "africa" }

    it_behaves_like "suggests alternatives", "africa1"

    context "and ends with numbers" do
      let(:input_value) { "africa123" }
      let(:group_value) { "africa123" }

      it_behaves_like "suggests alternatives", "africa124"
    end
  end

  context "when attribute is not enabled for suggestions" do
    let(:attribute) { "email" }
    let(:input_value) { "some_email@example.org" }
    let(:user_value) { "some_user_email@example.org" }
    let(:group_value) { "some_group_email@example.org" }

    it { is_expected.to be_valid }

    context "when suggest an existing user email" do
      let(:input_value) { user_value }

      it { is_expected.not_to be_valid }

      it "does not suggest an alternative word" do
        expect(subject.suggestion).to eq(input_value)
      end
    end

    context "when suggest an existing group email" do
      let(:input_value) { group_value }

      it { is_expected.not_to be_valid }

      it "does not suggest an alternative word" do
        expect(subject.suggestion).to eq(input_value)
      end
    end
  end

  context "when attribute is not supported" do
    let(:attribute) { "about" }

    it { is_expected.not_to be_valid }
  end
end
