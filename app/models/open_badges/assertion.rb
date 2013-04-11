require 'digest'
require 'securerandom'

module OpenBadges
  class Assertion < ActiveRecord::Base

    belongs_to :badge

    validates :badge_id, :verification_type, presence: true
    validates :identity, :identity_hashed, :identity_type, presence: true

    validates :badge, :presence => { message: "does not exists" }
    validates_uniqueness_of :user_id, :scope => :badge_id, message: "assertion exists"

    has_attached_file :image, :url => "/:class/:attachment/:id_baked_:filename",
      :default_url => "/open_badges/missing.png"
    
    attr_accessible :image, :user_id, :badge_id, :evidence, :expires
    attr_accessible :identity, :identity_hashed, :identity_salt, :identity_type
    attr_accessible :verification_type

    after_initialize :assign_defaults
    after_save :bake_image

    @@OPENBADGES_METADATA_KEY = 'openbadges'

    def Assertion.OPENBADGES_METADATA_KEY
      @@OPENBADGES_METADATA_KEY
    end

    private
    def assign_defaults
      if new_record?
        self.identity = 'sha256$'
        self.identity_hashed = true
        self.identity_type = 'email'
        self.identity_salt = SecureRandom.urlsafe_base64(16)

        self.verification_type = 'hosted'
      end
    end

    def bake_image
      if self.image?
        png = ChunkyPNG::Image.from_file(self.image.path)

        if !png.metadata.has_key? @@OPENBADGES_METADATA_KEY
            png.metadata[@@OPENBADGES_METADATA_KEY] = self.url
            png.save(self.image.path)
        end
      end
    end

    public
    def url
      OpenBadges::Engine.routes.url_helpers.assertion_url({
        :id => self.id,
        :format => :json,
        :host => Rails.application.config.default_url_options[:host]
      })
    end

    def image_url
      Rails.application.config.default_url_options[:host] + image.url
    end

    def as_json(options = nil)
      json = super( :only => [] )

      @organization = Organization.first || Organization.new

      json.merge!({
        :salt => self.identity_salt,
        :issued_on => self.created_at.to_date,
        :recipient => self.identity,
        :badge => {
          :name => self.badge.name,
          :version => '0.5.0',
          :image => self.badge.image_url,
          :description => self.badge.description,
          :issuer => {
            :org => @organization.name,
            :name => @organization.name,
            :origin => @organization.url,
            :contact => @organization.email
          }
        }
        :uid => self.id.to_s,
        :badge => self.badge.url,
        :issuedOn => self.created_at.to_i,
        :recipient => {
          :identity => self.identity,
          :type => self.identity_type,
          :salt => self.identity_salt,
          :hashed => self.identity_hashed
        },
        :verify => {
          :url => self.url,
          :type => self.verification_type
        },
        :image => (self.image_url unless !self.image?)
      })
      json[:evidence] = self.evidence unless self.evidence.nil? || self.evidence.empty?
      json[:expires] = self.expires.to_date unless self.expires.nil?

      json[:badge][:criteria] = self.badge.criteria unless self.badge.criteria.nil?
      json
    end

    # public
    # def as_json(options = nil)
    #   json = super( :only => [] )
    #   json.merge!({
    #     :uid => self.id.to_s,
    #     :badge => self.badge.url,
    #     :issuedOn => self.created_at.to_i,
    #     :recipient => {
    #       :identity => self.identity,
    #       :type => self.identity_type,
    #       :salt => self.identity_salt,
    #       :hashed => self.identity_hashed
    #     },
    #     :verify => {
    #       :url => self.url,
    #       :type => self.verification_type
    #     }
    #   })
    #   json[:image] = self.image unless self.image.nil? || self.image.empty?
    #   json[:evidence] = self.evidence unless self.evidence.nil? || self.evidence.empty?
    #   json[:expires] = self.expires.to_i unless self.expires.nil?
    #   json
    # end
  end
end
