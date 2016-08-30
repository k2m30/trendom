require 'gmail'

class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(profile_id, campaign_id, user_email, token, user_name)
    begin
      logger = MonoLogger.new('log/sending.log')
      logger.level = MonoLogger::INFO

      profile = Profile.find(profile_id)
      campaign = Campaign.find(campaign_id)
      if Rails.env.production? or Rails.env.development?
        gmail = Gmail.connect(:xoauth2, user_email, token)
        email = gmail.compose do
          to profile.emails.first
          subject campaign.subject
          text_part do
            body profile.apply_template(campaign.email_template_id)
          end
          from user_name if user_name.present?
        end
        email.deliver!
        logger.info("sent from #{user_email} to #{profile.emails.first}")
        sleep rand(60..80)
      else

      end
      size = campaign.profiles_ids.size.to_f

      sql = "UPDATE campaigns SET progress = progress + #{1.0/size*100.0}, sent = CASE WHEN progress + #{1.0/size*100.0} >= 100.0 THEN true ELSE false END WHERE id = #{campaign_id};"
      ActiveRecord::Base.connection.execute(sql)

    rescue => e
      logger.error [user_name, profile_id]
      logger.error e.message
      logger.error pp e.backtrace[0..4]
    end
  end
end
