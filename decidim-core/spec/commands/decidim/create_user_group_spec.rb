# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateUserGroup do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:user) { create :user, :confirmed, organization: organization }

        let(:name) { "User group name" }
        let(:nickname) { "nickname" }
        let(:email) { "user@myrealdomain.org" }
        let(:phone) { "Y1fERVzL2F" }
        let(:document_number) { "123456780X" }
        let(:about) { "This is us." }
        let(:avatar) { upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg")) }

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
            allow(form).to receive(:invalid?).and_return(true)
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

          it "creates a new user group" do
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

          it "notifies the admins" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .once
              .ordered
              .with(
                event: "decidim.events.groups.user_group_created",
                event_class: Decidim::UserGroupCreatedEvent,
                resource: an_object_satisfying { |obj| obj.is_a?(Decidim::UserGroup) },
                affected_users: a_collection_containing_exactly(*Decidim::User.where(organization: organization, admin: true).all)
              )

            command.call
          end
        end
      end
    end
  end
end
