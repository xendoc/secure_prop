require 'spec_helper'

class User
  extend ActiveModel::Callbacks
  include SecureProp

  define_model_callbacks :create

  has_secure :password

  attr_accessor :password_digest
end

describe SecureProp do
  it 'has a version number' do
    expect(SecureProp::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
