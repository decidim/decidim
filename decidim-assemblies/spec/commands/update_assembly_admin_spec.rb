# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::UpdateAssemblyAdmin do
    subject { described_class.new(form, user_role) }

    let!(:new_role) { "collaborator" }
    let!(:user_role) do
      user = create :assembly_admin
      Decidim::AssemblyUserRole.where(user: user).last
    end
    let(:form) do
      double(
        invalid?: invalid,
        role: new_role
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when there is no user role given" do
      let(:user_role) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "updates the user role" do
        expect do
          subject.call
        end.to change { user_role.reload && user_role.role }.from("admin").to(new_role)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
