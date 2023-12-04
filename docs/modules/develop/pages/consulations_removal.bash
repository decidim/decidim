#!/usr/bin/env bash
#
# Script to adapt migrations after consultations removal
# We did not use any of the solutions described at the "Data migrations consistency" [0] discussion,
# so when we try to run a migration in a non-existing table, it blows-up.
#
# This script fixes those migrations so they do not need the model in your application.
#
# [0] https://github.com/decidim/decidim/discussions/8068
#

if [ -f db/migrate/*_add_end_voting_date_to_decidim_consultations.decidim_consultations.rb ] ; then
  cat << 'EOFILE' > db/migrate/*_add_end_voting_date_to_decidim_consultations.decidim_consultations.rb
# This migration comes from decidim_consultations (originally 20180115132000)
# frozen_string_literal: true

class AddEndVotingDateToDecidimConsultations < ActiveRecord::Migration[5.1]
  class Consultation < ApplicationRecord
    self.table_name = :decidim_consultations
  end

  def change
    add_column :decidim_consultations, :end_voting_date, :date

    Consultation.find_each do |consultation|
      consultation.end_voting_date = consultation.start_voting_date + 1.month
      consultation.save
    end

    change_column_null :decidim_consultations, :end_voting_date, false
  end
end
EOFILE
fi

if [ -f db/migrate/*_add_slug_to_decidim_consultations_questions.decidim_consultations.rb ] ; then
  cat << EOFILE > db/migrate/*_add_slug_to_decidim_consultations_questions.decidim_consultations.rb
# This migration comes from decidim_consultations (originally 20180115170933)
# frozen_string_literal: true

class AddSlugToDecidimConsultationsQuestions < ActiveRecord::Migration[5.1]
  class Question < ApplicationRecord
    self.table_name = :decidim_consultations_questions
  end

  def change
    add_column :decidim_consultations_questions,
               :decidim_organization_id,
               :integer,
               index: {
                 name: 'index_decidim_questions_on_decidim_organization_id'
               }

    add_column :decidim_consultations_questions, :slug, :string

    Question.find_each do |question|
      question.decidim_organization_id = question.consultation.decidim_organization_id
      question.slug = "q-#{question.id}"
      question.save
    end

    change_column_null :decidim_consultations_questions, :decidim_organization_id, false
    change_column_null :decidim_consultations_questions, :slug, false

    add_index :decidim_consultations_questions,
              [:decidim_organization_id, :slug],
              name: "index_unique_question_slug_and_organization",
              unique: true
  end
end
EOFILE
fi

if [ -f db/migrate/*_add_commentable_counter_cache_to_consultations.decidim_consultations.rb ] ; then
  cat << EOFILE > db/migrate/*_add_commentable_counter_cache_to_consultations.decidim_consultations.rb
# frozen_string_literal: true
# This migration comes from decidim_consultations (originally 20200827154143)

class AddCommentableCounterCacheToConsultations < ActiveRecord::Migration[5.2]
  class Question < ApplicationRecord
    self.table_name = :decidim_consultations_questions
  end

  def change
    add_column :decidim_consultations_questions, :comments_count, :integer, null: false, default: 0, index: true
    Question.reset_column_information
    Question.find_each(&:update_comments_count)
  end
end
EOFILE
fi

if [ -f db/migrate/*_add_followable_counter_cache_to_consultations.decidim_consultations.rb ] ; then
  cat << EOFILE > db/migrate/*_add_followable_counter_cache_to_consultations.decidim_consultations.rb
# frozen_string_literal: true
# This migration comes from decidim_consultations (originally 20210310120626)

class AddFollowableCounterCacheToConsultations < ActiveRecord::Migration[5.2]
  class Question < ApplicationRecord
    self.table_name = :decidim_consultations_questions
  end

  def change
    add_column :decidim_consultations_questions, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Question.reset_column_information
        Question.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
EOFILE
fi
