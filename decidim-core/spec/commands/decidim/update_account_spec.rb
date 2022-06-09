# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed) }
    let(:data) do
      {
        name: user.name,
        nickname: user.nickname,
        email: user.email,
        password: nil,
        password_confirmation: nil,
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        locale: "es"
      }
    end

    let(:form) do
      AccountForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        locale: data[:locale]
      ).with_context(current_organization: user.organization, current_user: user)
    end

    context "when invalid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "doesn't update anything" do
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

      it "updates the users's nickname" do
        form.nickname = "pepito"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.nickname).to eq("pepito")
      end

      it "updates the personal url" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.personal_url).to eq("https://example.org")
      end

      it "updates the about text" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.about).to eq("This is a description of me")
      end

      it "updates the language preference" do
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.locale).to eq("es")
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
          form.avatar = upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg"))
        end

        it "updates the avatar" do
          command.call
          expect(user.reload.avatar).not_to be_blank
        end
      end

      describe "remove_avatar" do
        let(:user) { create(:user, avatar: upload_test_file(Decidim::Dev.test_file("avatar.jpg", "image/jpeg"))) }

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
          form.password = "pNY6h9crVtVHZbdE"
          form.password_confirmation = "pNY6h9crVtVHZbdE"
        end

        it "updates the password" do
          expect { command.call }.to broadcast(:ok)
          expect(user.reload.valid_password?("pNY6h9crVtVHZbdE")).to be(true)
        end
      end

      describe "when the avatar dimensions are too big" do
        let(:message) { "Avatar is too big." }

        before do
          form.avatar = user.avatar

          allow(form.avatar.blob).to receive(:byte_size).and_return(1000.megabytes)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when updating the profile" do
        it "notifies the user's followers" do
          follower = create(:user, organization: user.organization)
          create(:follow, followable: user, user: follower)

          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.users.profile_updated",
              event_class: Decidim::ProfileUpdatedEvent,
              resource: kind_of(Decidim::User),
              followers: [follower]
            )

          command.call
        end

        context "when updating other fields" do
          before do
            form.personal_url = user.personal_url
            form.about = user.about
          end

          it "does not notify the followers" do
            expect(Decidim::EventsManager).not_to receive(:publish)

            command.call
          end
        end
      end
    end
  end
end
