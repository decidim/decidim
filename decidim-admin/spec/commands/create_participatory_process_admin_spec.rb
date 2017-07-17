# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::CreateParticipatoryProcessAdmin do
  let(:my_process) { create :participatory_process }
  let!(:email) { "my_email@example.org" }
  let!(:role) { "admin" }
  let!(:name) { "Weird Guy" }
  let!(:user) { create :user, email: "my_email@example.org", organization: my_process.organization }
  let!(:current_user) { create :user, email: "some_email@example.org", organization: my_process.organization }
  let(:form) do
    double(
      invalid?: invalid,
      email: email,
      role: role,
      name: name
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, current_user, my_process) }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates the user role" do
      subject.call
      roles = Decidim::ParticipatoryProcessUserRole.where(user: user)

      expect(roles.count).to eq 1
      expect(roles.first.role).to eq "admin"
    end

    it "creates a new user with no application admin privileges" do
      subject.call
      expect(Decidim::User.last).not_to be_admin
    end

    context "when there is no user with the given email" do
      let(:email) { "does_not_exist@example.com" }

      it "creates a new user with said email" do
        subject.call
        expect(Decidim::User.last.email).to eq(email)
      end

      it "creates a new user with no application admin privileges" do
        subject.call
        expect(Decidim::User.last).not_to be_admin
      end
    end

    context "when a user and a role already exist" do
      before do
        subject.call
      end

      it "doesn't get created twice" do
        expect { subject.call }.to broadcast(:ok)

        roles = Decidim::ParticipatoryProcessUserRole.where(user: user)

        expect(roles.count).to eq 1
        expect(roles.first.role).to eq "admin"
      end
    end

    context "when the user hasn't accepted the invitation" do
      before do
        user.invite!
      end

      it "gets the invitation resent" do
        expect { subject.call }.to have_enqueued_job(ActionMailer::DeliveryJob)
      end
    end
  end
end
