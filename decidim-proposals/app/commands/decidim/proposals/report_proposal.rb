# frozen_string_literal: true
module Decidim
  module Proposals
    # A command with all the business logic when a user reports a proposal.
    class ReportProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # proposal     - The proposal being reported
      # current_user - The current user.
      def initialize(form, proposal, current_user)
        @form = form
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal report.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_proposal_report!
          update_report_count!
        end

        send_report_notification_to_admins

        if hideable_proposal?
          hide_proposal!
          send_hide_notification_to_admins
        end

        broadcast(:ok, proposal_report)
      end

      private

      attr_reader :form, :proposal_report

      def create_proposal_report!
        @proposal_report = ProposalReport.create!(
          proposal: @proposal,
          user: @current_user,
          reason: form.reason
        )
      end

      def update_report_count!
        @proposal.update_attributes!(report_count: @proposal.report_count + 1)
      end

      def participatory_process_admins
        @participatory_process_admins ||= Decidim::Admin::ProcessAdmins.for(@proposal.feature.participatory_process)
      end

      def send_report_notification_to_admins
        participatory_process_admins.each do |admin|
          ProposalReportedMailer.report(admin, @proposal_report).deliver_later
        end
      end

      def hideable_proposal?
        !@proposal.hidden? && @proposal.report_count >= Decidim.max_reports_before_hiding
      end

      def hide_proposal!
        Decidim::Proposals::Admin::HideProposal.new(@proposal).call
      end

      def send_hide_notification_to_admins
        participatory_process_admins.each do |admin|
          ProposalReportedMailer.hide(admin, @proposal_report).deliver_later
        end
      end
    end
  end
end
