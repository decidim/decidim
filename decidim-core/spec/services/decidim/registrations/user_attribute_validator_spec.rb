# frozen_string_literal: true

require "spec_helper"

describe Decidim::Registrations::UserAttributeValidator do
  subject { described_class.new(attribute: attribute, form: form, model_class: model_class) }

  let(:attribute) { "nickname" }
  let(:form) { Decidim::RegistrationForm.from_params(params).with_context(context) }
  let(:params) do
    {
      attribute => value
    }
  end
  let(:value) { "mali" }
  let(:model_class) { nil }
  let(:context) do
    {
     current_organization: organization
    }
  end
  let!(:user) { create :user, nickname: "zimbawe" }
  let!(:user_group) { create :user_group, nickname: "africa", organization: organization }
  let(:organization) { user.organization }

  shared_examples "validates and suggests nicknames" do
    it "is valid" do
      expect(subject.valid?).to be(true)
    end

    context "when nickname already exists" do
      let(:value) { "africa" }

      it "is invalid" do
        expect(subject.valid?).to be(false)
      end
    end
  end

  it "responds to form" do
    expect(subject.form).to eq(form)
  end

  it "model_class is Decidim::User" do
    expect(subject.model_class).to eq(Decidim::User)
  end

  it_behaves_like "validates and suggests nicknames"

  context "when model_class is provided" do
    let(:model_class) { Decidim::UserGroup }

    it "model_class is used" do
      expect(subject.model_class).to eq(Decidim::UserGroup)
    end

    it_behaves_like "validates and suggests nicknames"
  end
end
