# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateConference do
    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, :confirmed, organization: }
    let(:scope) { create :scope, organization: }
    let(:errors) { double.as_null_object }
    let!(:participatory_processes) do
      create_list(
        :participatory_process,
        3,
        organization:
      )
    end
    let!(:assemblies) do
      create_list(
        :assembly,
        3,
        organization:
      )
    end
    let(:consultation) { create :consultation, organization: }
    let!(:questions) do
      create_list(
        :question,
        3,
        consultation:
      )
    end
    let(:form) do
      instance_double(
        Admin::ConferenceForm,
        current_user:,
        invalid?: invalid,
        title: { en: "title" },
        slogan: { en: "slogan" },
        slug: "slug",
        hashtag: "hashtag",
        location: "location location",
        hero_image: nil,
        banner_image: nil,
        promoted: nil,
        description: { en: "description" },
        short_description: { en: "short_description" },
        current_organization: organization,
        scopes_enabled: true,
        scope:,
        errors:,
        show_statistics: false,
        objectives: { en: "objectives" },
        start_date: 1.day.from_now,
        end_date: 5.days.from_now,
        registrations_enabled: false,
        available_slots: 0,
        registration_terms: { en: "registrations terms" },
        participatory_processes_ids: participatory_processes.map(&:id),
        assemblies_ids: assemblies.map(&:id),
        consultations_ids: questions.collect(&:consultation).uniq
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the conference is not persisted" do
      let(:invalid_conference) do
        instance_double(
          Decidim::Conference,
          persisted?: false,
          valid?: false,
          errors: {
            hero_image: "File resolution is too large",
            banner_image: "File resolution is too large"
          }
        ).as_null_object
      end

      before do
        allow(Decidim::ActionLogger).to receive(:log).and_return(true)
        allow(Decidim::Conference).to receive(:create).and_return(invalid_conference)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds errors to the form" do
        expect(errors).to receive(:add).with(:hero_image, "File resolution is too large")
        expect(errors).to receive(:add).with(:banner_image, "File resolution is too large")
        subject.call
      end
    end

    context "when everything is ok" do
      let(:conference) { Decidim::Conference.last }

      it "creates an conference" do
        expect { subject.call }.to change(Decidim::Conference, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "adds the admins as followers" do
        subject.call
        expect(current_user.follows?(conference)).to be true
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create)
          .with(Decidim::Conference, current_user, kind_of(Hash))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      it "links participatory processes" do
        subject.call
        linked_participatory_processes = conference.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
        expect(linked_participatory_processes).to match_array(participatory_processes)
      end

      it "links assemblies" do
        subject.call
        linked_assemblies = conference.linked_participatory_space_resources(:assemblies, "included_assemblies")
        expect(linked_assemblies).to match_array(assemblies)
      end

      it "links consultations" do
        subject.call
        linked_consultations = conference.linked_participatory_space_resources("Consultations", "included_consultations")
        expect(linked_consultations).to match_array(questions.collect(&:consultation).uniq)
      end
    end
  end
end
