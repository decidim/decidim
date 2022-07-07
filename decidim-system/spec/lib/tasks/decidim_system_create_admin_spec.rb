# frozen_string_literal: true

require "spec_helper"

describe "decidim_system:create_admin", type: :task do
  let(:email) { "system@example.org" }
  let(:password) { "Test123456" }
  let(:password_confirmation) { password }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  context "with arguments" do
    before do
      allow($stdin).to receive(:gets).and_return(email)
      allow($stdin).to receive(:noecho).and_return(password, password_confirmation)
    end

    it "runs gracefully" do
      expect { task.execute }.not_to raise_error
    end

    context "when there are existing system admins" do
      let!(:system_admin) { create(:admin) }

      it "warns that there are already existing admins" do
        task.execute
        expect($stdout.string).to include("currently there are existing system admins")
      end
    end

    context "when provided data is valid" do
      it "creates an admin" do
        expect { task.execute }.to change(Decidim::System::Admin, :count).by(1)
        expect($stdout.string).to include("System admin created successfully")
      end
    end

    context "when provided data is invalid" do
      context "when passwords don't match" do
        let(:email) { "invalid" }
        let(:password_confirmation) { "invalid" }

        it "prevents creation of admin and displays validation errors" do
          expect { task.execute }.not_to(change(Decidim::System::Admin, :count))

          expect($stdout.string).to include("Some errors prevented creation of admin")
          expect($stdout.string).to include("Email is invalid")
          expect($stdout.string).to include("Password confirmation doesn't match Password")
        end
      end

      context "when password is too common" do
        let(:password) { "password1234" }
        let(:password_confirmation) { "password1234" }

        it "prevents creation of admin and displays validation errors" do
          expect { task.execute }.not_to(change(Decidim::System::Admin, :count))

          expect($stdout.string).to include("Some errors prevented creation of admin")
          expect($stdout.string).to include("Password is too common")
        end
      end
    end
  end
end
