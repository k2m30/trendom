require 'gmail'
require_relative 'email_helper'

class SendBatchEmailsJob < ApplicationJob
  queue_as :default

  def perform(campaign_id, user_email, token, user_name)
    @logger = MonoLogger.new('log/sending.log')
    @logger.level = MonoLogger::INFO

    campaign = Campaign.find(campaign_id)
    profiles = campaign.profiles
    campaign_size = campaign.profiles.size.to_f

    @logger.info([campaign_id, campaign_size, user_email, user_name])

    if Rails.env.production? or Rails.env.development?
      gmail = Gmail.connect(:xoauth2, user_email, refresh_token(token))
      profiles.each do |profile|
        begin
          email = compose_email(gmail, profile, profile.emails.first, campaign, user_name)
          email.deliver!
          @logger.info("sent from #{user_email} to #{profile.emails.first}")

          sql = "UPDATE campaigns SET progress = progress + #{1.0/campaign_size*100.0}, sent = CASE WHEN progress + #{1.0/campaign_size*100.0} >= 99.5 THEN true ELSE false END WHERE id = #{campaign_id};"
          ActiveRecord::Base.connection.execute(sql)

          sleep rand(2..6)
        rescue => e
          @logger.error [user_name, profile.id]
          @logger.error e.message
          @logger.error pp e.backtrace[0..4]
        end
      end
    end
  end
end
