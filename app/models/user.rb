class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Timestamps::Updated

  field :email, type: String
  field :name, type: String
  field :image, type: String
  field :uid, type: String
  field :plan, type: String, default: ''
  field :subscription_expires, type: DateTime
  field :card_holder_name, type: String
  field :street_address, type: String
  field :street_address2, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :country, type: String
  field :billing_email, type: String
  field :phone, type: String
  field :card_number, type: String
  field :calls_left, type: Integer, default: 0
  field :progress, type: Float, default: 0.0
  field :tkn, type: String
  field :expires_at, type: DateTime
  field :profiles_ids, type: Array, default: []
  field :campaigns_sent_ids, type: Array, default: []
  field :order_number, type: String
  field :refresh_tkn, type: String

  field :encrypted_password
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: DateTime
  field :last_sign_in_at, type: DateTime
  field :current_sign_in_ip
  field :last_sign_in_ip

  store_in collection: 'trendomUser'
  embeds_many :email_templates, cascade_callbacks: true
  embeds_many :campaigns, cascade_callbacks: true

  devise :database_authenticatable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]

  # serialize :revealed_ids
  # serialize :campaigns_sent_ids

  # has_and_belongs_to_many :profiles

  after_create :create_email_templates

  def profiles
    Profile.in(id: self.profiles_ids)
  end

  def self.create_test_data
    User.find_by(email: 'mikhail.chuprynski@gmail.com').update(profiles: [], subscription_expires: Time.now + 1.month, calls_left: 10)
    User.find_by(email: 'mikhail.chuprynski@gmail.com').campaigns.destroy_all
    url = Rails.env.production? ? 'trendom.io' : 'localhost:3000'

    Typhoeus::Request.new("http://#{url}/people/find",
                          method: :post,
                          body: '{"source":"linkedin","uid":"102594557413371756317","email":"mikhail.chuprynski@gmail.com","version":1,"data":[{"name":"Darrell Stein","id":"1","public_id":"ADEAAAQOEvYBA-OAyL36p-eDoeeh8LC6ZHHO-QU","position":"Cio at RB","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAOAAAAAJDhmZGZkMjZkLWE4MDgtNGUyMS04MTUwLTM2NjY2NTBlMmRjNA.jpg"},{"name":"Naveed Rajput","id":"2","public_id":"ADEAAABbB1MBxBAWFFYJLpZ_QT0Cm_cBk24G_y4","position":"CIO Advisory, Corp Strategy(Transformation & M&A), Reg Strategy - Cap Markets | Asset & Wealth Mgmt at PwC","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Tony Sweeney","id":"3","public_id":"ADEAAAA8dxcBcFzUAA3vFkeIjWTqI16FrBQaPUE","position":"CIO  Howden International at Hyperion Insurance Group","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/4/005/02f/01b/3157c8c.jpg"},{"name":"PJ Jassal","id":"4","public_id":"ADEAAAEBj7oB3Glw5LZfhKFIyHiIFwoHQvoVppY","position":"CIO at Encore Tickets Ltd","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/2/000/1ca/34b/08be0c8.jpg"},{"name":"Anthony Woolley","id":"5","public_id":"ADEAAABxc-EBNrePY4HxFboHjAelTpu_d8T38sE","position":"UK CIO at Societe Generale","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Richard Gael","id":"6","public_id":"ADEAABUxNFUBtr8NY2WND_RE0jBRAIdko56yquI","position":"CTO  / CIO Headhunter at Specialist Technology Leader Practice","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/5/005/072/058/0409511.jpg"},{"name":"David Weir","id":"7","public_id":"ADEAAAxGGUgBptcvSjXrn8rKJCGpdLfK26boZvc","position":"CIO/CTO at Totemic Technology Ltd","location":"Leeds, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/3/005/078/235/2f2501e.jpg"},{"name":"James Gilbert","id":"8","public_id":"ADEAAAJBNSkBjaecQN_AHcb6IlPaVYTea7XALeI","position":"Head of the CIO Office at RBS Markets and International Banking","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Gideon Kay","id":"11","public_id":"ADEAAAAQjQYBpXYRRsaTueioo057NImcHxa8BWo","position":"Group CIO (Interim) & EMEA CIO at Dentsu Aegis Network","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAdEAAAAJGNmYWJkMWQ0LTA2NWUtNDY3Mi04ZThjLWRkMjliNmI5OWYzNA.jpg"},{"name":"Nigel Sterndale","id":"12","public_id":"ADEAAAA_S8ABXMCopEcZeWw4tPZXB9DC_rjnjOM","position":"CIO at Totaljobs Group Ltd (a StepStone Group company)","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/1/005/090/147/2b93ab9.jpg"}]}',
                          headers: {'Content-Type': 'application/json'}
    ).run

    Typhoeus::Request.new("http://#{url}/home/add_profiles",
                          method: :post,
                          body: '{"source":"linkedin","uid":"102594557413371756317","email":"mikhail.chuprynski@gmail.com","version":1,"data":[{"name":"Darrell Stein","id":"1","public_id":"ADEAAAQOEvYBA-OAyL36p-eDoeeh8LC6ZHHO-QU","position":"Cio at RB","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAOAAAAAJDhmZGZkMjZkLWE4MDgtNGUyMS04MTUwLTM2NjY2NTBlMmRjNA.jpg"},{"name":"Naveed Rajput","id":"2","public_id":"ADEAAABbB1MBxBAWFFYJLpZ_QT0Cm_cBk24G_y4","position":"CIO Advisory, Corp Strategy(Transformation & M&A), Reg Strategy - Cap Markets | Asset & Wealth Mgmt at PwC","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Tony Sweeney","id":"3","public_id":"ADEAAAA8dxcBcFzUAA3vFkeIjWTqI16FrBQaPUE","position":"CIO  Howden International at Hyperion Insurance Group","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/4/005/02f/01b/3157c8c.jpg"},{"name":"PJ Jassal","id":"4","public_id":"ADEAAAEBj7oB3Glw5LZfhKFIyHiIFwoHQvoVppY","position":"CIO at Encore Tickets Ltd","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/2/000/1ca/34b/08be0c8.jpg"},{"name":"Anthony Woolley","id":"5","public_id":"ADEAAABxc-EBNrePY4HxFboHjAelTpu_d8T38sE","position":"UK CIO at Societe Generale","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Richard Gael","id":"6","public_id":"ADEAABUxNFUBtr8NY2WND_RE0jBRAIdko56yquI","position":"CTO  / CIO Headhunter at Specialist Technology Leader Practice","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/5/005/072/058/0409511.jpg"},{"name":"David Weir","id":"7","public_id":"ADEAAAxGGUgBptcvSjXrn8rKJCGpdLfK26boZvc","position":"CIO/CTO at Totemic Technology Ltd","location":"Leeds, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/3/005/078/235/2f2501e.jpg"},{"name":"James Gilbert","id":"8","public_id":"ADEAAAJBNSkBjaecQN_AHcb6IlPaVYTea7XALeI","position":"Head of the CIO Office at RBS Markets and International Banking","location":"London, United Kingdom","photo":"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"},{"name":"Gideon Kay","id":"11","public_id":"ADEAAAAQjQYBpXYRRsaTueioo057NImcHxa8BWo","position":"Group CIO (Interim) & EMEA CIO at Dentsu Aegis Network","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAdEAAAAJGNmYWJkMWQ0LTA2NWUtNDY3Mi04ZThjLWRkMjliNmI5OWYzNA.jpg"},{"name":"Nigel Sterndale","id":"12","public_id":"ADEAAAA_S8ABXMCopEcZeWw4tPZXB9DC_rjnjOM","position":"CIO at Totaljobs Group Ltd (a StepStone Group company)","location":"London, United Kingdom","photo":"https://media.licdn.com/mpr/mpr/shrink_100_100/p/1/005/090/147/2b93ab9.jpg"}]}',
                          headers: {'Content-Type': 'application/json'}
    ).run
  end

  def active?
    active = (calls_left > 0 and Time.now < subscription_expires)
    update(plan: 'Free') unless active
    active
  end

  def profiles_not_in_campaigns
    ids = campaigns.pluck(:profiles_ids)
    profiles.not_in(id: ids.flatten)
  end

  def add_profiles(params)
    request = UserRequest.new(params)
    case request.source
      when :linkedin
        profiles_to_add = Profile.in(id: request.ids - self.profiles_ids)
        profiles_to_add.each do |profile|
          begin
            if self.calls_left > 0 and !self.profiles_ids.include?(profile.id)
              self.update(calls_left: self.calls_left - 1, profiles_ids: self.profiles_ids << profile.id)
            end
          rescue => e
            logger.fatal(e.message)
            logger.fatal(profile.id)
            logger.fatal(profile.linkedin_id)
          end
        end
      when :facebook
      when :twitter
    end
  end

  def self.create_with_uid_and_email(uid, email)
    User.create(email: email,
                password: Devise.friendly_token[0, 20],
                uid: uid,
                calls_left: 80,
                plan: 'Free',
                subscription_expires: Time.now)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by(email: data[:email])

    unless user
      user = User.create(name: data[:name],
                         email: data[:email],
                         password: Devise.friendly_token[0, 20],
                         image: data[:image],
                         calls_left: 80,
                         plan: 'Free',
                         uid: access_token[:uid],
                         subscription_expires: Time.now)
    end
    user.update_with_omniauth(access_token) if user.image.nil?
    user.update(tkn: access_token.credentials.token, expires_at: access_token.credentials.expires_at, refresh_tkn: access_token.credentials.refresh_token)
    user
  end

  def update_with_omniauth(access_token)
    data = access_token.info
    update(name: data[:name],
           email: data[:email],
           password: Devise.friendly_token[0, 20],
           image: data[:image],
           uid: access_token[:uid])
  end

  def export_profiles(options = {})
    columns = %w(name position email location linkedin_url photo)
    CSV.generate(options) do |csv|
      csv << columns.map(&:capitalize)
      profiles_with_revealed_emails.each do |profile|
        line = [profile.name, profile.position, profile.emails.first, profile.location, profile.linkedin_url, profile.photo]
        csv << line
      end
    end
  end

  def plan?(p)
    plan.downcase == p.downcase
  end

  protected
  def create_email_templates
    templates = YAML.load(File.read('config/templates.yml'))
    templates.keys.each do |key|
      self.email_templates.create(name: key, subject: templates[key]['subject'], text: templates[key]['body'])
    end
  end
end