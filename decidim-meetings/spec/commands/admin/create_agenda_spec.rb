# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::CreateAgenda do
    subject { described_class.new(form, meeting) }

    let(:organization) { create :organization, available_locales: [:en] }
    let(:component) { create(:component, manifest_name: "meetings", organization:) }
    let(:meeting) { create(:meeting, component:) }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }

    let(:invalid) { false }
    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        visible: :visible,
        agenda_items: [
          double(
            title: { en: "title" },
            description: { en: "description" },
            position: 1,
            duration: 2.hours,
            parent_id: nil,
            deleted?: false,
            agenda_item_children: [
              double(
                title: { en: "title child 1" },
                description: { en: "description child 1" },
                position: 1,
                duration: 1.hour,
                parent_id: nil,
                deleted?: false
              ),
              double(
                title: { en: "title child 2" },
                description: { en: "description child 2" },
                position: 2,
                duration: 1.hour,
                parent_id: nil,
                deleted?: false
              )
            ]
          )
        ],
        current_user:
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:agenda) { Agenda.last }
      let(:agenda_item) { agenda.agenda_items.first }

      it "creates the meeting agenda and agenda items" do
        expect { subject.call }.to change(Agenda, :count).by(1)
        expect { subject.call }.to change(AgendaItem, :count).by(3)
      end

      it "correctly sets the children items" do
        subject.call
        expect(translated(agenda_item.title)).to eq("title")
        expect(agenda_item.agenda_item_children.size).to eq(2)
        expect(agenda_item.agenda_item_children.order(:position).map(&:title)).to eq([{ "en" => "title child 1" }, { "en" => "title child 2" }])
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(Agenda, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
