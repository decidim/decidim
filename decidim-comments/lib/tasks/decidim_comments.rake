# frozen_string_literal: true

namespace :decidim_comments do
  desc "Adds participatory_process_id to comments if they are associated with a participatory process"
  task update_participatory_process_in_comments: :environment do
    puts "Updating comments..."
    ok = errors = 0

    log = ActiveSupport::Logger.new(Rails.root.join("log/update_participatory_process_in_comments.log"))
    Decidim::Comments::Comment.where(participatory_space: nil).find_each do |c|
      c.participatory_space = if c.root_commentable.is_a?(Decidim::Participable)
                                c.root_commentable
                              else
                                c.commentable.try(:participatory_space)
                              end
      c.save(validate: false)
      ok += 1
    rescue StandardError => e
      errors += 1
      log.info "Error updating comment ##{c.id}: #{e.message}"
    end

    puts "#{ok} comments updated."
    puts "#{errors} errors found. Check the file 'log/update_participatory_process_in_comments.log' for more information." if errors.positive?
  end
end
