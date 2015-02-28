# SecureProp

SecureProp is an extension of ActiveModel::SecurePassword.
It is almost the same.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'secure_prop', github: 'xendoc/secure_prop'
```

## Usage

In your class:

```ruby
class User
  include SecureProp
  has_secure :password

  attr_accessor :name, :password_digest
end

user = User.new
user.password = 'password'
user.password_digest # => "$2a$10$HXj/2y6.PYINe60vQYW0aOiJcHy/jZmQzFiWmvOMPTJABOvdEitMO"

user.authenticate(:password, 'notright')  # false
user.authenticate(:password, 'password')  # user
```

Adds methods to set and authenticate against a BCrypt property.
This mechanism requires you to have a `#{property}_digest` attribute.

The following validations are added automatically:
* Property must be present on creation
* Property length should be less than or equal to 72 characters
* Confirmation of property (using a `#{property}_confirmation` attribute)

If property confirmation validation is not needed, simply leave out the
value for `#{property}_confirmation` (i.e. don't provide a form field for it). When this attribute has a `nil` value, the validation will not be triggered.

For further customizability, it is possible to supress the default validations by passing `validations: false` as an argument.

Multi Properties:

```ruby
class User
  include SecureProp
  has_secure [:password, :phrase]

  attr_accessor :name, :password_digest, :phrase_digest
end
```

ActiveRecord:

```sh
$ rails generate model User name:string password_digest:string
```

```ruby
class User < ActiveRecord::Base
  include SecureProp
  has_secure :password
end

User.create(name: 'username', password: 'password')

user = User.find_by(name: 'username').try(:authenticate, :password, 'notright') # false
user = User.find_by(name: 'username').try(:authenticate, :password, 'password') # user
```

## License

SecureProp is available under the MIT license.
