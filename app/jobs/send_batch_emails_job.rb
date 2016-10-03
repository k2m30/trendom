require 'gmail'

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
          email = gmail.compose do
            subject, body = profile.apply_template(campaign.email_template_id)
            first, last = profile.split_name
            to "#{first} #{last} <#{profile.emails.first}>"
            subject subject
            text_part do
              body body
            end
            from user_name if user_name.present?
          end
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

  def refresh_token(token)
    @logger.info([ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']])
    client = OAuth2::Client.new(ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {site: 'https://accounts.google.com', authorize_url: '/o/oauth2/auth', token_url: '/o/oauth2/token'})
    response = OAuth2::AccessToken.from_hash(client, refresh_token: token).refresh!
    @logger.info(response.token)
    response.token
  end
end
