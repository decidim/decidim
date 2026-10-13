# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::DestroyRegistrationType, versioning: true do
    subject { described_class.new(registration_type, current_user) }

    let(:conference) { create(:conference) }
    let(:registration_type) { create(:registration_type, conference:) }
    let!(:current_user) { create(:user, :confirmed, organization: conference.organization) }

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: registration_type.title
          },
          participatory_space: {
            title: conference.title
          }
        }
      end

      it "destroys the registration type" do
        subject.call
        expect { registration_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, registration_type, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end

    context "when the registration type has registrations" do
      let!(:conference_registration) { create(:conference_registration, conference:, registration_type:, user: current_user) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not destroy the registration type" do
        subject.call

        expect { registration_type.reload }.not_to raise_error
      end
    end

    context "when the check and the deletion share the transaction" do
      include_context "with concurrency"

      # Fixtures are created eagerly so the captured queries only contain the command's own
      # transaction.
      let!(:conference) { create(:conference) }
      let!(:registration_type) { create(:registration_type, conference:) }

      it "locks the registration type, checks for registrations and deletes in the same transaction" do
        queries = capture_queries { subject.call }

        begin_index = queries.index { |sql| sql == "BEGIN" }
        lock = queries.index { |sql| sql.include?("FOR UPDATE") && sql.include?("decidim_conferences_registration_types") }
        check = queries.index { |sql| sql.include?("decidim_conferences_conference_registrations") }
        delete = queries.index { |sql| sql.include?("DELETE FROM \"decidim_conferences_registration_types\"") }
        commit = queries.index { |sql| sql == "COMMIT" }

        expect(begin_index).not_to be_nil
        expect(lock).not_to be_nil
        expect(check).not_to be_nil
        expect(delete).not_to be_nil
        expect(commit).not_to be_nil
        expect(begin_index).to be < lock
        expect(lock).to be < check
        expect(check).to be < delete
        expect(delete).to be < commit
      end
    end

    context "when a registration is created while the command runs" do
      include_context "with concurrency"

      # Fixtures must be committed before the threads start, since transactional tests are disabled
      # and `let` memoization is not thread-safe.
      let!(:conference) { create(:conference) }
      let!(:current_user) { create(:user, :confirmed, organization: conference.organization) }
      let!(:registration_type) { create(:registration_type, conference:) }

      it "never destroys the type while a committed registration references it" do
        events = []
        errors = []
        gate = Queue.new

        creator = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            gate.pop
            Decidim::Conferences::ConferenceRegistration.create!(conference:, user: current_user, registration_type: Decidim::Conferences::RegistrationType.find(registration_type.id))
          end
        rescue ActiveRecord::Deadlocked, ActiveRecord::ForeignKeyViolation => e
          errors << e
        end

        destroyer = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            gate.pop
            recorder = Decidim::EventRecorder.new
            command = described_class.new(Decidim::Conferences::RegistrationType.find(registration_type.id), current_user)
            command.subscribe(recorder)
            command.call
            events.concat(recorder.events.keys)
          end
        end

        2.times { gate << true }
        [creator, destroyer].each(&:join)

        # Whichever flow acquires the lock first, the outcome is consistent: a surviving type still
        # has its registration, and a destroyed type has none. Without the shared lock the check
        # could pass while the insert was in flight and the cascade would unregister the participant.
        surviving = Decidim::Conferences::RegistrationType.find_by(id: registration_type.id)
        if surviving
          expect(Decidim::Conferences::ConferenceRegistration.where(decidim_conference_registration_type_id: surviving.id).count).to eq(1)
          expect(events).to eq([:invalid])
        else
          expect(Decidim::Conferences::ConferenceRegistration.where(decidim_conference_registration_type_id: registration_type.id).count).to eq(0)
          expect(events).to eq([:ok])
        end

        # JoinConference locks the conference before the type and the destroy only locks the type,
        # so the two flows cannot deadlock.
        expect(errors).not_to include(an_instance_of(ActiveRecord::Deadlocked))
      end
    end

    def capture_queries
      queries = []
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") { |_, _, _, _, data| queries << data[:sql] }
      yield
      queries
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
