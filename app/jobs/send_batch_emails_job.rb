require 'gmail'
require_relative 'email_helper'

class SendBatchEmailsJob < ApplicationJob
  queue_as :default

  def perform(user_id, campaign_id)
    @logger = MonoLogger.new('log/sending.log')
    @logger.level = MonoLogger::INFO

    user = User.find(user_id)
    campaign = user.campaigns.find(campaign_id)
    profiles = campaign.profiles
    campaign_size = campaign.profiles.size.to_f

    @logger.info([campaign_id, campaign_size, user.email, user.name])

    if Rails.env.production? or Rails.env.development?
      gmail = Gmail.connect(:xoauth2, user.email, refresh_token(user.refresh_tkn))
      profiles.each do |profile|
        begin
          email = compose_email(gmail, profile, profile.emails.first, campaign, user)
          email.deliver!
          @logger.info("sent from #{user.email} to #{profile.emails.first}")

          campaign.update(progress: campaign.progress + 1.0/campaign_size*100.0)
          # sql = "UPDATE campaigns SET progress = progress + #{1.0/campaign_size*100.0}, sent = CASE WHEN progress + #{1.0/campaign_size*100.0} >= 99.5 THEN true ELSE false END WHERE id = #{campaign_id};"
          sleep rand(2..6)
        rescue => e
          @logger.error [user.name, profile.id]
          @logger.error e.message
          @logger.error pp e.backtrace[0..4]
        end
      end
    end
  end
end
