# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AccountForm do
    subject do
      described_class.new(
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        avatar: avatar,
        remove_avatar: remove_avatar
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:name) { "Lord of the Foo" }
    let(:email) { "depths@ofthe.bar" }
    let(:password) { "abcde123" }
    let(:password_confirmation) { password }
    let(:avatar) { File.open("spec/assets/avatar.jpg") }
    let(:remove_avatar) { false }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty name" do
      let(:name) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    describe "email" do
      context "with an empty email" do
        let(:email) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in the same organization" do
        let!(:existing_user) { create(:user, email: email, organization: organization) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, email: email) }

        it "is invalid" do
          expect(subject).to be_valid
        end
      end
    end
  end
end
