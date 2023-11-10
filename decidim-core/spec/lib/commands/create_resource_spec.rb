# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::CreateResource do
    subject do
      klass = Class.new(Decidim::Commands::CreateResource) do
        fetch_form_attributes :title, :body, :component

        def resource_class = Decidim::DummyResources::DummyResource

        def attributes = super.merge(author: form.current_user)
      end
      klass.new(form)
    end

    let(:user) { create(:user, organization: current_component.organization) }
    let(:current_component) { create(:dummy_component) }

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

              def resource_class = Decidim::DummyResources::DummyResource

              def attributes = super.merge(author: form.current_user)

              def run_before_hooks = raise Decidim::Commands::HookError
            end
            klass.new(form)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when after hook is failing" do
          subject do
            klass = Class.new(described_class) do
              fetch_form_attributes :title, :body, :component

              def resource_class = Decidim::DummyResources::DummyResource

              def attributes = super.merge(author: form.current_user)

              def run_after_hooks = raise Decidim::Commands::HookError
            end
            klass.new(form)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end
    end

    context "when everything is ok" do
      it "creates the status" do
        expect { subject.call }.to change(Decidim::DummyResources::DummyResource, :count).by(1)
      end

      context "when invalid data" do
        let(:user) { nil }

        it "raises error when invalid date is submitted" do
          expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "when traces the action", versioning: true do
        it "traces the action" do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:create, Decidim::DummyResources::DummyResource, user, {})
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("create")
          expect(action_log.version).to be_present
        end

        context "when extra params are passed" do
          subject do
            klass = Class.new(Decidim::Commands::CreateResource) do
              fetch_form_attributes :title, :body, :component

              def resource_class = Decidim::DummyResources::DummyResource

              def attributes = super.merge(author: form.current_user)

              def extra_params = { visibility: "all" }
            end
            klass.new(form)
          end

          it "traces the action" do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::DummyResources::DummyResource, user, { visibility: "all" })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
          end
        end
      end
    end
  end
end
