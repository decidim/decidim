# frozen_string_literal: true

class MoveProposalsFieldsToI18n < ActiveRecord::Migration[5.2]
  class Proposal < ApplicationRecord
    include Decidim::HasComponent

    self.table_name = :decidim_proposals_proposals
  end

  class Coauthorship < ApplicationRecord
    self.table_name = :decidim_coauthorships
  end

  class UserBaseEntity < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def up
    add_column :decidim_proposals_proposals, :new_title, :jsonb
    add_column :decidim_proposals_proposals, :new_body, :jsonb

    PaperTrail.request(enabled: false) do
      Proposal.find_each do |proposal|
        coauthorship = Coauthorship.order(:id).find_by(coauthorable_type: "Decidim::Proposals::Proposal", coauthorable_id: proposal.id)
        author =
          if coauthorship.decidim_author_type == "Decidim::Organization"
            Organization.find_by(id: coauthorship.decidim_author_id)
          else
            UserBaseEntity.find_by(id: coauthorship.decidim_author_id)
          end

        locale = if author
                   author.try(:locale).presence || author.try(:default_locale).presence || author.try(:organization).try(:default_locale).presence
                 elsif proposal.component && proposal.component.participatory_space
                   proposal.component.participatory_space.organization.default_locale
                 else
                   I18n.default_locale.to_s
                 end

        proposal.new_title = {
          locale => proposal.title
        }
        proposal.new_body = {
          locale => proposal.body
        }

        proposal.save(validate: false)
      end
    end

    remove_indexs

    remove_column :decidim_proposals_proposals, :title
    rename_column :decidim_proposals_proposals, :new_title, :title
    remove_column :decidim_proposals_proposals, :body
    rename_column :decidim_proposals_proposals, :new_body, :body

    create_indexs
  end

  def down
    add_column :decidim_proposals_proposals, :new_title, :string
    add_column :decidim_proposals_proposals, :new_body, :string

    Proposal.find_each do |proposal|
      proposal.new_title = proposal.title.values.first
      proposal.new_body = proposal.body.values.first

      proposal.save!
    end

    remove_indexs

    remove_column :decidim_proposals_proposals, :title
    rename_column :decidim_proposals_proposals, :new_title, :title
    remove_column :decidim_proposals_proposals, :body
    rename_column :decidim_proposals_proposals, :new_body, :body

    create_indexs
  end

  def remove_indexs
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_title_search"
    remove_index :decidim_proposals_proposals, name: "decidim_proposals_proposal_body_search"
  end

  def create_indexs
    execute "CREATE INDEX decidim_proposals_proposal_title_search ON decidim_proposals_proposals(md5(title::text))"
    execute "CREATE INDEX decidim_proposals_proposal_body_search ON decidim_proposals_proposals(md5(body::text))"
  end
end
