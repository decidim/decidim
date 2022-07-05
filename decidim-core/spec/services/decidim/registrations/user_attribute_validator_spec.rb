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

  it "responds to form" do
    expect(subject.form).to eq(form)
  end

  it { is_expected.to be_valid }

  it "does not have errors" do
    expect(subject.error).to be_blank
  end

  context "when attribute already belongs to a user" do
    let!(:user) { create :user, :organization => organization, attribute.to_sym => user_value }
    let(:input_value) { "zimbawe" }

    it "returns an error message" do
      expect(subject.error).to include("already been taken")
    end
  end

  context "when attribute already belongs to a group" do
    let!(:user_group) { create :user_group, :organization => organization, attribute.to_sym => group_value }
    let(:input_value) { "africa" }

    it "returns an error message" do
      expect(subject.error).to include("already been taken")
    end
  end

  context "when attribute is not supported" do
    let(:attribute) { "about" }

    it { is_expected.not_to be_valid }

    it "returns an error message" do
      expect(subject.error).to include("Invalid attribute")
    end
  end

  context "when attribute has dependant validations" do
    let(:attribute) { :password }
    let(:name) { "Africa Unite 1979" }
    let(:input_value) { "africaunite1979" }
    let(:params) do
      {
        name: name,
        password: input_value,
        password_confirmation: input_value,
        attribute: attribute
      }
    end

    it { is_expected.not_to be_valid }

    it "returns an error message" do
      expect(subject.error).to include("Is too similar to your name")
    end

    context "and depency is ok" do
      let(:name) { "Survival" }

      it { is_expected.to be_valid }
    end
  end
end
