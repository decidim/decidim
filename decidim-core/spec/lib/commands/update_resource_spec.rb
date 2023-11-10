# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::UpdateResource do
    subject do
      klass = Class.new(Decidim::Commands::UpdateResource) do
        fetch_form_attributes :title, :body, :component

        def resource_class = Decidim::DummyResources::DummyResource

        def attributes = super.merge(author: form.current_user)
      end
      klass.new(form, resource)
    end

    let(:resource) { create(:dummy_resource) }
    let(:user) { create(:user, organization: current_component.organization) }
    let(:current_component) { resource.component }

    let(:invalid) { false }

    let(:form) do
      double(
        invalid?: invalid,
        current_user: user,
        component: current_component,
        title: { en: "title" },
        body: { en: "body" }
      )
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      context "when hooks are failing" do
        let(:invalid) { false }

        context "when before hook is failing" do
          subject do
            klass = Class.new(described_class) do
              fetch_form_attributes :title, :body, :component
              def attributes = super.merge(author: form.current_user)

              def run_before_hooks = raise Decidim::Commands::HookError
            end
            klass.new(form, resource)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when after hook is failing" do
          subject do
            klass = Class.new(described_class) do
              fetch_form_attributes :title, :body, :component
              def attributes = super.merge(author: form.current_user)

              def run_after_hooks = raise Decidim::Commands::HookError
            end
            klass.new(form, resource)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end
    end

    context "when everything is ok" do
      it "sets the name" do
        subject.call
        expect(translated(resource.title)).to eq "title"
      end

      context "when traces the action", versioning: true do
        it "traces the action" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, Decidim::DummyResources::DummyResource, user, {})
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("update")
          expect(action_log.version).to be_present
        end

        context "when extra params are passed" do
          subject do
            klass = Class.new(described_class) do
              fetch_form_attributes :title, :body, :component

              def resource_class = Decidim::DummyResources::DummyResource

              def attributes = super.merge(author: form.current_user)

              def extra_params = { visibility: "all" }
            end
            klass.new(form, resource)
          end

          it "traces the action" do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:update, Decidim::DummyResources::DummyResource, user, { visibility: "all" })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
          end
        end
      end
    end
  end
end
