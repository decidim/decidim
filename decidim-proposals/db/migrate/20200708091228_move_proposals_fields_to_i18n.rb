# frozen_string_literal: true

class MoveProposalsFieldsToI18n < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_proposals_proposals, :new_title, :jsonb
    add_column :decidim_proposals_proposals, :new_body, :jsonb

    reset_column_information

    PaperTrail.request(enabled: false) do
      Decidim::Proposals::Proposal.find_each do |proposal|
        author = proposal.coauthorships.first.author

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

    reset_column_information
  end

  def down
    add_column :decidim_proposals_proposals, :new_title, :string
    add_column :decidim_proposals_proposals, :new_body, :string

    reset_column_information

    Decidim::Proposals::Proposal.find_each do |proposal|
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

    reset_column_information
  end

  def reset_column_information
    Decidim::User.reset_column_information
    Decidim::Coauthorship.reset_column_information
    Decidim::Proposals::Proposal.reset_column_information
    Decidim::Organization.reset_column_information
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
