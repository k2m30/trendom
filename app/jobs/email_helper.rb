def compose_email(gmail, profile, email_to, campaign, user_name)
  gmail.compose do
    subject, body = profile.apply_template(campaign.email_template_id)
    first, last = profile.split_name
    to "#{first} #{last} <#{email_to}>"
    subject subject
    text_part do
      body body
    end
    from user_name if user_name.present?
  end
end

def refresh_token(token)
  @logger.info([ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']])
  client = OAuth2::Client.new(ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {site: 'https://accounts.google.com', authorize_url: '/o/oauth2/auth', token_url: '/o/oauth2/token'})
  response = OAuth2::AccessToken.from_hash(client, refresh_token: token).refresh!
  @logger.info(response.token)
  response.token
end
