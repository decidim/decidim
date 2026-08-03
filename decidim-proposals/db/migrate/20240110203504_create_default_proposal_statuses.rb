# frozen_string_literal: true

class CreateDefaultProposalStatuses < ActiveRecord::Migration[6.1]
  class CustomProposal < ApplicationRecord
    belongs_to :proposal_state,
               class_name: "ProposalStatus",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: :proposals,
               optional: true

    self.table_name = :decidim_proposals_proposals
    STATES = { not_answered: 0, evaluating: 10, accepted: 20, rejected: -10 }.freeze
    enum :old_state, STATES, default: "not_answered"
  end

  class ProposalStatus < ApplicationRecord
    self.table_name = :decidim_proposals_proposal_states
  end

  def up
    CustomProposal.reset_column_information
    ProposalStatus.reset_column_information
    Decidim::Component.unscoped.where(manifest_name: "proposals").find_each do |component|
      default_states = create_default_statuses(component)

      CustomProposal.where(decidim_component_id: component.id).find_each do |proposal|
        next if proposal.old_state == "not_answered"

        token = default_states[proposal.old_state.to_sym]&.token
        proposal.update!(proposal_state: ProposalStatus.where(decidim_component_id: component.id, token:).first!)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def create_default_statuses(component)
    colors = Decidim::Proposals.proposal_statuses_colors
    locale = Decidim.default_locale
    {
      evaluating: {
        token: :evaluating,
        bg_color: colors[:orange][:background],
        text_color: colors[:orange][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_in_evaluation_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:evaluating, scope: "decidim.proposals.answers") } }
      },
      accepted: {
        token: :accepted,
        bg_color: colors[:green][:background],
        text_color: colors[:green][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_accepted_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:accepted, scope: "decidim.proposals.answers") } }
      },
      rejected: {
        token: :rejected,
        bg_color: colors[:red][:background],
        text_color: colors[:red][:foreground],
        announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_rejected_reason", scope: "decidim.proposals.proposals.show") } },
        title: { locale => I18n.with_locale(locale) { I18n.t(:rejected, scope: "decidim.proposals.answers") } }
      }
    }.transform_values do |attributes|
      ProposalStatus.create!(decidim_component_id: component.id, **attributes)
    end
  end
end
