# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::UpdateAgenda do
    subject { described_class.new(form, agenda) }

    let(:agenda_item_child) { create(:agenda_item, :with_parent) }
    let(:agenda_item) { agenda_item_child.parent }
    let(:agenda) { agenda_item.agenda }
    let(:meeting) { agenda.meeting }
    let(:organization) { meeting.component.organization }
    let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }

    let(:deleted) { false }
    let(:attributes) do
      {
        id: agenda.id,
        title: { en: "new title" },
        visible: :visible,
        agenda_items: [
          {
            id: agenda_item.id,
            title: { en: "new item title" },
            description: { en: "new item description" },
            position: agenda_item.position,
            duration: agenda_item.duration,
            parent_id: agenda_item.parent_id,
            deleted: false,
            agenda_item_children: [
              {
                id: agenda_item_child.id,
                title: { en: "new title child 1" },
                description: { en: "new description child 1" },
                position: agenda_item_child.position,
                duration: agenda_item_child.duration,
                parent_id: agenda_item.parent_id,
                deleted: deleted
              }
            ]
          }
        ]
      }
    end
    let(:form) do
      Admin::MeetingAgendaForm.from_params(
        attributes
      ).with_context(
        meeting: meeting,
        current_user: current_user,
        current_organization: organization
      )
    end

    context "when the form is not valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      before do
        subject.call
      end

      it "updates the meeting agenda and agenda items" do
        expect(translated(agenda.reload.title)).to eq("new title")
        expect(translated(agenda_item.reload.title)).to eq("new item title")
        expect(translated(agenda_item_child.reload.title)).to eq("new title child 1")
      end

      context "and an agenda item is removed" do
        let(:deleted) { true }

        it "removes the agenda item" do
          expect(agenda.reload.agenda_items.count).to eq(1)
        end
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(Agenda, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
