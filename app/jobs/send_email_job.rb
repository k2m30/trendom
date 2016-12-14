require 'gmail'
require_relative 'email_helper'

class SendEmailJob < ApplicationJob
  queue_as :default

  def perform(profile_id, campaign_id, email_to, email_from, token, user_name)
    @logger = MonoLogger.new('log/sending.log')
    @logger.level = MonoLogger::INFO

    campaign = Campaign.find(campaign_id)
    profile = Profile.find(profile_id)

    if Rails.env.production? or Rails.env.development?
      begin
        gmail = Gmail.connect(:xoauth2, email_from, refresh_token(token))
        email = compose_email gmail, profile, email_to, campaign, user_name
        email.deliver!
        @logger.info("sent test email from #{email_from} to #{profile.emails.first}")
      rescue => e
        @logger.error [user_name, profile.id]
        @logger.error e.message
        @logger.error pp e.backtrace[0..4]
      end
    end
  end
end
