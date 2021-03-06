class UserRequest
  attr_accessor :profiles, :uid, :email, :source

  def initialize(params)
    @profiles = []

    hash = JSON.parse(JSON[params.to_unsafe_h], symbolize_names: true)
    @uid = hash[:uid]
    @email = hash[:email]
    @source = hash[:source].to_sym

    if hash[:data].is_a? String
      hash[:data] = JSON.parse(hash[:data].gsub('=>', ':'))
      hash[:data].map {|h| h.to_unsafe_h.deep_symbolize_keys!}
    end

    hash[:data].map do |json|
      @profiles << Person.new(json, @source)
    end
  end

  def [](id)
    @profiles.select{|profile| profile.id.to_i == id.to_i }.first
  end

  def ids
    @profiles.map(&:id).map(&:to_s)
  end
end

class Person
  attr_accessor :name, :social_network, :position, :location, :photo, :id, :public_id

  def initialize(json, source)
    @name = json[:name]
    @social_network = source
    @public_id = json[:public_id]
    @position = json[:position]
    @location = json[:location]
    @photo = json[:photo]
    @id = json[:id]
  end
# {"name" => "Greg Barnett",
#  "source" => {"id" => "112123234", "public_id" => "ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4", "social_network" => "linkedin"},
#  "position" => "Co Founder & CTO at StarStock ltd",
#  "Location" => "London, United Kingdom",
#  "photo" => "https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAXZAAAAJGE2OTQwZTkwLTM1OTYtNDc1YS05MDdhLTAzZmYyYTE5ODAwYw.jpg", "url" => "https://www.linkedin.com/profile/view?id=ADEAAAau3WIBXuhln8uvxcEEG7Hb5M1I74oQyh4&authType=OUT_OF_NETWORK&authToken=cOxw&locale=en_US&srchid=4120029691459362192716&srchindex=91&srchtotal=179817&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%3A4120029691459362192716%2CVSRPtargetId%3A112123234%2CVSRPcmpt%3Aprimary%2CVSRPnm%3Afalse%2CauthType%3AOUT_OF_NETWORK",
#  "email" => "0 emails available",
#  "id" => "112123234"}
end