require "spec_helper"

describe Decidim::Admin::CreateParticipatoryProcessAdmin do
  let(:my_process) { create :participatory_process }
  let!(:email) { "my_email@example.org" }
  let!(:user) { create :user, email: "my_email@example.org", organization: my_process.organization }
  let(:form) do
    double(
      :invalid? => invalid,
      email: email
    )
  end
  let(:invalid) { false }

  subject { described_class.new(form, my_process) }

  context "when to form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when there is no user with the given email" do
    let(:email) { "does_not_exist@example.com" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    it "creates the user role" do
      subject.call
      roles = Decidim::Admin::ParticipatoryProcessUserRole.where(user: user)

      expect(roles.count).to eq 1
      expect(roles.first.role).to eq "admin"
    end
  end

  # context "when the process is nil" do
  #   let(:my_process) { nil }
  #
  #   it "is not valid" do
  #     expect { subject.call }.to broadcast(:invalid)
  #   end
  # end
  #
  # context "when the process is published" do
  #   let(:my_process) { create :participatory_process }
  #
  #   it "is not valid" do
  #     expect { subject.call }.to broadcast(:invalid)
  #   end
  # end
  #
  # context "when the process is not published" do
  #   it "is valid" do
  #     expect { subject.call }.to broadcast(:ok)
  #   end
  #
  #   it "publishes it" do
  #     subject.call
  #     my_process.reload
  #     expect(my_process).to be_published
  #   end
  # end
end
