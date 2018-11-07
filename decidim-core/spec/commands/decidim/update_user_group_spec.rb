# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe UpdateUserGroup do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create :user, :confirmed, organization: organization }
        let(:user_group) { create :user_group, users: [user], organization: organization }

        let(:name) { "My super duper group" }
        let(:nickname) { "new_nickname" }
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
        let(:command) { described_class.new(form, user_group) }

        context "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the user group" do
            expect do
              command.call
              user_group.reload
            end.not_to change(user_group, :name)
          end
        end

        context "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the user group" do
            command.call
            user_group.reload

            expect(user_group.name).to eq "My super duper group"
          end

          context "when the avatar is not updated" do
            let(:avatar) { nil }

            it "keeps the old avatar" do
              command.call
              user_group.reload

              expect(user_group.avatar).to be_present
            end
          end
        end
      end
    end
  end
end
