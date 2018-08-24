# frozen_string_literal: true

require "spec_helper"

module Decidim::Amendable
  describe Create do
    let(:resource) { create(:dummy_resource) }
    let(:amender) { create(:user, :confirmed, organization: resource.organization) }
    let!(:command) { described_class.new(form) }

    let(:form) do
      Decidim::Amendable::CreateForm.from_params(form_params).with_context(form_context)
    end

    let(:emendation_fields) do
      {
        title: "Loura Hansen II 1"
      }
    end

    let(:form_params) do
      {
        amendable_gid: resource.to_sgid.to_s,
        emendation_fields: emendation_fields,
        amender: amender,
        component: resource.component
      }
    end

    let(:form_context) do
      {
        current_user: amender,
        current_organization: resource.organization,
        current_participatory_space: resource.participatory_space,
        current_component: resource.component
      }
    end

    context "when the form is invalid" do
      let(:form_params) do
        {
          amendable_gid: nil,
          emendation_fields: nil,
          amender: nil,
          component: resource.component
        }
      end

      it "does not create a amendment" do
        expect { command.call }.not_to change(Decidim::Amendment, :count)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "does not send notifications" do
        expect do
          perform_enqueued_jobs { command.call }
        end.not_to change(emails, :count)
      end
    end

    context "when the form is valid" do
      it "creates an amendment and the emendation" do
        expect { command.call }
          .to change(Decidim::Amendment, :count)
          .by(1)
          .and change(resource.resource_manifest.model_class_name.constantize, :count)
          .by(1)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "notifies the authors and followers of the amendable resource" do
        command.call
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.amendments.amendment_created",
            event_class: Decidim::Amendable::AmendmentCreatedEvent,
            resource: resource,
            recipient_ids: [resource.author] + resource.followers,
            extra: {
              amendment_id: kind_of(Decidim::Amendment)
            }
          )
      end
    end
  end
end
