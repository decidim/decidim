require "spec_helper"

module Decidim
  describe UpdateAccount, perform_enqueued: true do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user) }
    let(:valid) { true }
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
      double(
        name: data[:name],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        valid?: valid
      )
    end

    context "when invalid" do
      let(:valid) { false }

      it "Doesn't update anything" do
        data[:name] = "John Doe"
        old_name = user.name
        expect { command.call }.to broadcast(:invalid)
        expect(user.reload.name).to eq(old_name)
      end
    end

    context "when valid" do
      let(:valid) { true }

      it "updates the users's name" do
        data[:name] = "Pepito de los palotes"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.name).to eq("Pepito de los palotes")
      end

      describe "updating the email" do
        before do
          data[:email] = "new@email.com"
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "sends a reconfirmation email" do
          expect { command.call }.to change{ emails.length }.by(1)
          expect(last_email.to).to include("new@email.com")
        end
      end

      describe "avatar" do
        before do
          data[:avatar] = File.open("spec/assets/avatar.jpg")
        end

        it "updates the avatar" do
          command.call
          expect(user.reload.avatar).to_not be_blank
        end
      end

      describe "remove_avatar" do
        let(:user) { create(:user, avatar: File.open("spec/assets/avatar.jpg")) }

        before do
          data[:remove_avatar] = true
        end

        it "removes the avatar" do
          command.call
          expect(user.reload.avatar).to be_blank
        end
      end

      describe "when the password is present" do
        before do
          data[:password] = "test123"
          data[:password_confirmation] = "test123"
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:ok)
          expect(user.reload.valid_password?("test123")).to eq(true)
        end
      end
    end
  end
end
