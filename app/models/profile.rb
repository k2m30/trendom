# require_relative 'pipl_db'
require 'trendom_db'
require_relative 'user_request'
# require 'email_verifier'
# require 'google_custom_search_api'

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  include Mongoid::Document
  field :'_class', type: String

  field :'firstName', as: :first_name, type: String
  field :'lastName', as: :last_name, type: String
  field :'headline', type: String

  field :'profilePictureURL', as: :picture_url, type: String
  field :'liId', as: :li_id, type: String
  field :'linkedinTimestamp', type: BSON::Date

  field :'privateEmail', as: :private_email, type: Hash
  field :'corporateEmails', as: :corporate_emails, type: Array
  field :'otherEmails', as: :other_emails, type: Array

  field :'mainLocation', as: :main_location, type: Hash
  field :'currentPositions', as: :current_positions, type: Array
  field :'boundAccounts', type: Array
  field :'imAccounts', type: Array
  field :'phones', type: Array

  field :'publicProfileURL', as: :public_url, type: String
  field :'siteStandardProfileRequest', as: :site_standard_request, type: Hash

  field :'schemaVer', as: :version, type: Integer

  # 1st conections
  field :'industry', type: String

  #data
  field :'rawDataObjects', as: :raw_data_objects, type: Array, default: []

  #indexes
  index({_id: 1}, {unique: true, background: true})
  index({headline: 1}, {background: true})

  store_in collection: 'linkedinProfile'

  def apply_template(email_template_id, user)
    #TODO add {My Name} placeholder
    email_template = user.email_templates.find(email_template_id)
    body = apply(email_template.text)
    subject = apply(email_template.subject)
    return subject, body
  end

  def apply(text)
    text.gsub('{First Name}', first_name).gsub('{Last Name}', last_name).gsub('{Company}', extract_company).gsub('{Position}', extract_position)
  end

  def set_primary_email(main_email)
    return unless emails.include?(main_email)
    a = emails
    a.delete(main_email)
    a.insert(0, main_email)
    self.update(emails: a)
  end

  def extract_company
    headline.split(' at ').last || ''
  end

  def name
    "#{first_name} #{last_name}"
  end

  def extract_position
    headline.split(' at ').first || ''
  end

  # def get_emails_from_trendom(update = true)
  #   return [] if linkedin_id.nil?
  #   logger.info("started search #{name}: #{Time.now.to_f}")
  #   email = TrendomLinkedinDb.new(linkedin_id).get_email
  #   logger.info("finished search #{name}: #{Time.now.to_f}")
  #
  #   return [] if email.nil?
  #
  #   name, domain = email.split('@')
  #   return [] if name.nil? or domain.nil?
  #
  #   update(emails: [email], emails_available: 1, source: :trendom) if update
  #   TrendomEmailVerificationService.new([{id: linkedin_id, email: email}]).call
  #
  #   [email]
  # end

  def self.get_emails_available(params)
    #TODO add '-1' to hash when user already has this email
    hash = {}
    request = UserRequest.new(params)
    ids = request.ids.map(&:to_s)
    case request.source
      when :linkedin
        profiles = Profile.in(id: ids)
        hash = profiles.pluck(:id, :emails_available).to_h
        (ids - profiles.pluck(:id)).each do |id|
          p = request[id]
          fn, ln = p.name.split(' ').map(&:capitalize)
          profile = Profile.create(id: p.id, site_standard_request: {url: "https://www.linkedin.com/profile/view?id=#{p.public_id}".freeze},
                                   first_name: fn, last_name: ln,
                                   headline: p.position, main_location: {name: p.location}, picture_url: p.photo)
          #TODO send all them at once
          # profile.get_emails_from_trendom
          hash[p.id] = 0 #profile.emails_available
        end
      when :facebook

    end
    hash
  end

  def emails
    pe = private_email.nil? ? nil : private_email[:email]
    ces = corporate_emails.nil? ? nil : corporate_emails.map{|c| c[:email]}
    [ pe, ces ].flatten.compact
  end
end