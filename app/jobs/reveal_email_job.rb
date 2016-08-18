class RevealEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id, profile_id, increment)
    user = User.find(user_id)

    if user.calls_left.zero?
      return
    end

    if user.revealed_ids.include?(profile_id)
      sql = "UPDATE users SET progress = progress + #{increment} WHERE id = #{user_id};"
      ActiveRecord::Base.connection.execute(sql)
      return
    end

    profile = user.profiles.find(profile_id)
    return unless profile

    profile.with_lock do
      profile.get_emails
    end

    sql = "UPDATE users SET calls_left = calls_left - 1, progress = progress + #{increment}, revealed_ids = revealed_ids || #{profile_id} WHERE id = #{user_id};"
    ActiveRecord::Base.connection.execute(sql)
  end
end
