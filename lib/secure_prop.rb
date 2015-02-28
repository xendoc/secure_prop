require "secure_prop/version"
require 'bcrypt'
require "active_model"
require "active_support"

module SecureProp
  extend ActiveSupport::Concern

  # BCrypt hash function can handle maximum 72 characters, and if we pass
  # property of length more than 72 characters it ignores extra characters.
  # Hence need to put a restriction on property length.
  MAX_PROPERTY_LENGTH_ALLOWED = 72

  class << self
    attr_accessor :min_cost # :nodoc:
  end
  self.min_cost = false

  module ClassMethods
    # Adds methods to set and authenticate against a BCrypt property.
    # This mechanism requires you to have a +#{property}_digest+ attribute.
    #
    # The following validations are added automatically:
    # * Property must be present on creation
    # * Property length should be less than or equal to 72 characters
    # * Confirmation of property (using a +#{property}_confirmation+ attribute)
    #
    # If property confirmation validation is not needed, simply leave out the
    # value for +#{property}_confirmation+ (i.e. don't provide a form field for
    # it). When this attribute has a +nil+ value, the validation will not be
    # triggered.
    #
    # For further customizability, it is possible to supress the default
    # validations by passing <tt>validations: false</tt> as an argument.
    #
    #
    # Example using Active Record
    #
    #   # Schema: User(name:string, password_digest:string)
    #   class User < ActiveRecord::Base
    #     has_secure :password
    #   end
    #
    #   user = User.new(name: 'david', password: '', password_confirmation: 'nomatch')
    #   user.save                                                                   # => false, password required
    #   user.password = 'mUc3m00RsqyRe'
    #   user.save                                                                   # => false, confirmation doesn't match
    #   user.password_confirmation = 'mUc3m00RsqyRe'
    #   user.save                                                                   # => true
    #   user.authenticate(:password, 'notright')                                    # => false
    #   user.authenticate(:password, 'mUc3m00RsqyRe')                               # => user
    #   User.find_by(name: 'david').try(:authenticate, :password, 'notright')       # => false
    #   User.find_by(name: 'david').try(:authenticate, :password, 'mUc3m00RsqyRe')  # => user
    def has_secure(properties, options = {})
      include InstanceMethodsOnActivation
      [properties].flatten.each do |property|
        class_eval <<-__METHODS__
          attr_reader :#{property}

          # Encrypts the password into the +password_digest+ attribute, only if the
          # new password is not empty.
          #
          #   class User < ActiveRecord::Base
          #     include SecureProp
          #     has_secure :password, validations: false
          #   end
          #
          #   user = User.new
          #   user.password = nil
          #   user.password_digest # => nil
          #   user.password = 'mUc3m00RsqyRe'
          #   user.password_digest # => "$2a$10$4LEA7r4YmNHtvlAvHhsYAeZmk/xeUVtMTYqwIvYY76EW5GUqDiP4."
          def #{property}=(unencrypted_property)
            if unencrypted_property.nil?
              self.#{property}_digest = nil
            elsif !unencrypted_property.empty?
              @#{property} = unencrypted_property
              cost = SecureProp.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
              self.#{property}_digest = BCrypt::Password.create(unencrypted_property, cost: cost)
            end
          end

          def #{property}_confirmation=(unencrypted_property)
            @#{property}_confirmation = unencrypted_property
          end
        __METHODS__
      end

      if options.fetch(:validations, true)
        include ActiveModel::Validations

        [properties].flatten.each do |property|
          eval <<-__VALIDATES__
            # This ensures the model has a password by checking whether the password_digest
            # is present, so that this works with both new and existing records. However,
            # when there is an error, the message is added to the password attribute instead
            # so that the error message will make sense to the end-user.
            validate do |record|
              unless record.#{property}.present?
                record.errors.add(:#{property}, :blank)
              end
            end

            validates_length_of :#{property}, maximum: SecureProp::MAX_PROPERTY_LENGTH_ALLOWED
            validates_confirmation_of :#{property}, allow_blank: true
          __VALIDATES__
        end
      end
    end
  end

  module InstanceMethodsOnActivation
    # Returns +self+ if the password is correct, otherwise +false+.
    #
    #   class User < ActiveRecord::Base
    #     has_secure :password validations: false
    #   end
    #
    #   user = User.new(name: 'david', password: 'mUc3m00RsqyRe')
    #   user.save
    #   user.authenticate(:passowrd, 'notright')      # => false
    #   user.authenticate(:passowrd, 'mUc3m00RsqyRe') # => user
    def authenticate(property, unencrypted_property)
      BCrypt::Password.new(eval("#{property}_digest")).is_password?(unencrypted_property) && self
    end
  end
end
