# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateUserGroup do
      describe "call" do
        let(:organization) { create(:organization, :with_tos) }
        let(:user) { create :user, :confirmed, organization: organization }

        let(:name) { "User group name" }
        let(:nickname) { "nickname" }
        let(:email) { "user@myrealdomain.org" }
        let(:phone) { "Y1fERVzL2F" }
        let(:document_number) { "123456780X" }
        let(:about) { "This is us." }
        let(:avatar) { File.open("spec/assets/avatar.jpg") }

        let(:form_params) do
          {
            "group" => {
              "name" => name,
              "nickname" => nickname,
              "email" => email,
              "phone" => phone,
              "document_number" => document_number,
              "about" => about,
              "avatar" => avatar
            }
          }
        end
        let(:form) do
          UserGroupForm.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a user group" do
            expect do
              command.call
            end.not_to change(UserGroup, :count)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(UserGroup).to receive(:create!).with(
              name: form.name,
              nickname: form.nickname,
              email: form.email,
              avatar: form.avatar,
              about: form.about,
              organization: organization,
              extended_data: {
                phone: form.phone,
                document_number: form.document_number
              }
            ).and_call_original

            expect { command.call }.to change(UserGroup, :count).by(1)
          end

          it "creates the membership with a creator role" do
            command.call
            membership = UserGroupMembership.last
            expect(membership.user).to eq user
            expect(membership.role).to eq "creator"
          end
        end
      end
    end
  end
end
