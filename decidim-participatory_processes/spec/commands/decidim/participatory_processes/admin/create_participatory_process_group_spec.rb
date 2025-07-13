# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::CreateParticipatoryProcessGroup do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :admin, organization:) }
    let(:errors) { double.as_null_object }
    let(:form) do
      instance_double(
        Admin::ParticipatoryProcessGroupForm,
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        group_url: "http://example.org",
        hero_image: nil,
        current_organization: organization,
        organization:,
        current_user:,
        participatory_process_ids: [],
        developer_group: { en: "developer group" },
        local_area: { en: "local area" },
        meta_scope: { en: "meta scope" },
        target: { en: "target" },
        participatory_scope: { en: "participatory scope" },
        participatory_structure: { en: "participatory structure" },
        promoted: true
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a participatory process group" do
        expect { subject.call }.to change(Decidim::ParticipatoryProcessGroup, :count).by(1)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create)
          .with(Decidim::ParticipatoryProcessGroup, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
