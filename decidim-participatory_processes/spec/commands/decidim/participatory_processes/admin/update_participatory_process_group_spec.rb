# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcessGroup do
    subject { described_class.new(participatory_process_group, form) }

    let(:organization) { create :organization }
    let(:participatory_process_group) { create :participatory_process_group, organization: }
    let(:current_user) { create :user, :admin, :confirmed, organization: }
    let(:invalid) { false }
    let(:title_en) { "title es" }
    let(:developer_group) { participatory_process_group.developer_group }

    let(:params) do
      {
        participatory_process_group: {
          id: participatory_process_group.id,
          title_en:,
          title_es: "title es",
          title_ca: "title ca",
          description_en: "description en",
          description_es: "description es",
          description_ca: "description ca",
          hashtag: "hashtag",
          group_url: "http://example.org",
          hero_image: nil,
          current_organization: organization,
          current_user:,
          participatory_process_ids: [],
          developer_group:,
          local_area: participatory_process_group.local_area,
          meta_scope: participatory_process_group.meta_scope,
          target: participatory_process_group.target,
          participatory_scope: participatory_process_group.participatory_scope,
          participatory_structure: participatory_process_group.participatory_structure
        }
      }
    end
    let(:context) do
      {
        current_organization: organization,
        current_user:,
        process_group_id: participatory_process_group.id
      }
    end
    let(:form) do
      Admin::ParticipatoryProcessGroupForm.from_params(params).with_context(context)
    end

    context "when the form is not valid" do
      let(:title_en) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "doesn't update the participatory group process" do
        subject.call
        participatory_process_group.reload

        expect(participatory_process_group.title["en"]).not_to eq("title es")
      end

      it "adds errors to the form" do
        subject.call
        expect(form.errors[:title_en]).not_to be_empty
      end
    end

    context "when everything is ok" do
      let(:title_en) { "new_title" }
      let(:developer_group) { { en: "new developer group" } }

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "updates the participatory group process" do
        expect { subject.call }.to broadcast(:ok)
        participatory_process_group.reload

        expect(participatory_process_group.title["en"]).to eq("new_title")
        expect(participatory_process_group.developer_group["en"]).to eq("new developer group")
      end

      it "traces the creation", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(
            "update",
            Decidim::ParticipatoryProcessGroup,
            current_user
          ).and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
