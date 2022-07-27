# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::DestroyAssemblyMember, versioning: true do
    subject { described_class.new(assembly_member, current_user) }

    let(:assembly) { create(:assembly) }
    let(:assembly_member) { create :assembly_member, assembly: }
    let!(:current_user) { create :user, :confirmed, organization: assembly.organization }

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: assembly_member.full_name
          },
          participatory_space: {
            title: assembly.title
          }
        }
      end

      it "destroys the assembly member" do
        subject.call
        expect { assembly_member.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", assembly_member, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
