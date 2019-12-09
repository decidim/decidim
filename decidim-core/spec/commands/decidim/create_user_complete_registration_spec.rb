# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CreateUserCompleteRegistration do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:organization) { user.organization }
    let(:interested_scope) { create :scope, organization: organization }
    let(:ignored_scope) { create :scope, organization: organization }
    let(:ignored_area) { create :area, organization: organization }
    let(:data) do
      {
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        scopes: {
          ignored_scope.id.to_s => {
            "checked": "0",
            "id": ignored_scope.id.to_s
          },
          interested_scope.id.to_s => {
            "checked": "1",
            "id": interested_scope.id.to_s
          }
        }
      }
    end

    let(:form) do
      UserCompleteRegistrationForm.from_params(
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        scopes: data[:scopes]
      ).with_context(current_organization: organization, current_user: user)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "doesn't update anything" do
        form.personal_url = "http://wadus.com"
        old_personal_url = user.personal_url
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.personal_url).to eq(old_personal_url)
      end
    end

    context "when valid" do
      it "updates the personal url" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.personal_url).to eq("https://example.org")
      end

      it "updates the about text" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.about).to eq("This is a description of me")
      end

      describe "avatar" do
        before do
          form.avatar = File.open("spec/assets/avatar.jpg")
        end

        it "updates the avatar" do
          command.call
          expect(user.reload.avatar).not_to be_blank
        end
      end

      describe "remove_avatar" do
        let(:user) { create(:user, avatar: File.open("spec/assets/avatar.jpg")) }

        before do
          form.remove_avatar = true
        end

        it "removes the avatar" do
          command.call
          expect(user.reload.avatar).to be_blank
        end
      end

      it "updates the users's interested scopes" do
        expect { command.call }.to broadcast(:ok)
        user.reload
        expect(user.interested_scopes).to eq [interested_scope]
      end
    end
  end
end
