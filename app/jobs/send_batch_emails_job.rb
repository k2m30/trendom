require 'gmail'

class SendBatchEmailsJob < ApplicationJob
  queue_as :default

  def perform(profile_ids, campaign_id, user_email, token, user_name)
    logger = MonoLogger.new('log/sending.log')
    logger.level = MonoLogger::INFO

    logger.info([profile_ids, campaign_id, user_email, token, user_name])

    profiles = Profile.where(id: profile_ids)
    campaign = Campaign.find(campaign_id)
    campaign_size = campaign.profiles_ids.size.to_f

    if Rails.env.production? or Rails.env.development?
      gmail = Gmail.connect(:xoauth2, user_email, token)
      profiles.each do |profile|
        begin
          email = gmail.compose do
            subject, body = profile.apply_template(campaign.email_template_id)
            to profile.emails.first
            subject subject
            text_part do
              body body
            end
            from user_name if user_name.present?
          end
          email.deliver!
          logger.info("sent from #{user_email} to #{profile.emails.first}")
          sleep rand(2..6)

          sql = "UPDATE campaigns SET progress = progress + #{1.0/campaign_size*100.0}, sent = CASE WHEN progress + #{1.0/campaign_size*100.0} >= 99.5 THEN true ELSE false END WHERE id = #{campaign_id};"
          ActiveRecord::Base.connection.execute(sql)
        rescue => e
          logger.error [user_name, profile_id]
          logger.error e.message
          logger.error pp e.backtrace[0..4]
        end
      end
    end
  end
end
