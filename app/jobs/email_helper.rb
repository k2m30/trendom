def compose_email(gmail, profile, email_to, campaign, user)
  gmail.compose do
    subject, body = profile.apply_template(campaign.email_template_id, user)

    to "#{profile.first_name} #{profile.last_name} <#{email_to}>"
    subject subject
    body body
    from user.name if user.name.present?
  end
end

def refresh_token(token)
  @logger.info([ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']])
  client = OAuth2::Client.new(ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {site: 'https://accounts.google.com', authorize_url: '/o/oauth2/auth', token_url: '/o/oauth2/token'})
  response = OAuth2::AccessToken.from_hash(client, refresh_token: token).refresh!
  @logger.info(response.token)
  response.token
end
