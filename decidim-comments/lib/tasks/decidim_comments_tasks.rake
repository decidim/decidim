# frozen_string_literal: true

namespace :decidim do
  desc "Adds participatory_process_id to comments if they are associated with a participatory process"
  task update_participatory_process_in_comments: :environment do
    Decidim::Comments::Comment.find_each do |c|
      c.participatory_space = c.commentable.try(:participatory_space)
      c.save(validate: false)
    end
  end
end
