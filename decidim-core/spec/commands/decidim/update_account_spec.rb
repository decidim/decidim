# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed) }
    let(:data) do
      {
        name: user.name,
        email: user.email,
        password: nil,
        password_confirmation: nil,
        avatar: nil,
        remove_avatar: nil
      }
    end

    let(:form) do
      AccountForm.from_params(
        name: data[:name],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar]
      ).with_context(current_organization: user.organization, current_user: user)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "Doesn't update anything" do
        form.name = "John Doe"
        old_name = user.name
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.name).to eq(old_name)
      end
    end

    context "when valid" do
      it "updates the users's name" do
        form.name = "Pepito de los palotes"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.name).to eq("Pepito de los palotes")
      end

      describe "updating the email" do
        before do
          form.email = "new@email.com"
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "sends a reconfirmation email" do
          expect do
            perform_enqueued_jobs { command.call }
          end.to broadcast(:ok, true)
          expect(last_email.to).to include("new@email.com")
        end
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

      describe "when the password is present" do
        before do
          form.password = "test123"
          form.password_confirmation = "test123"
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:ok)
          expect(user.reload.valid_password?("test123")).to eq(true)
        end
      end

      describe "when the avatar dimensions are too big" do
        let(:message) { "Avatar is too big." }

        before do
          form.avatar = user.avatar

          allow(form.avatar).to receive(:size).and_return(1000.megabytes)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
