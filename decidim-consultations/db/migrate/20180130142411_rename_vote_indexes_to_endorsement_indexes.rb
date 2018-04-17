# frozen_string_literal: true

class RenameVoteIndexesToEndorsementIndexes < ActiveRecord::Migration[5.1]
  def change
    rename_index :decidim_consultations_endorsements,
                 :index_consultations_votes_on_author,
                 :index_consultations_endorsements_on_author

    rename_index :decidim_consultations_endorsements,
                 :index_consultations_votes_on_consultation_question,
                 :index_consultations_endorsements_on_consultation_question

    reversible do |dir|
      dir.up { create_authorable_unique }
      dir.down { create_author_unique }
    end
  end

  def create_authorable_unique
    remove_index :decidim_consultations_endorsements, name: "index_question_votes_author_unique"

    add_index :decidim_consultations_endorsements,
              %w(decidim_consultation_question_id decidim_author_id decidim_user_group_id),
              name: "index_question_votes_author_unique",
              unique: true
  end

  def create_author_unique
    remove_index :decidim_consultations_endorsements, name: "index_question_votes_author_unique"

    add_index :decidim_consultations_endorsements,
              %w(decidim_consultation_question_id decidim_author_id),
              name: "index_question_votes_author_unique",
              unique: true
  end
end
