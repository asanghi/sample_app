# == Schema Information
# Schema version: 20100831143218
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base 
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :name, :presence => true, :length => {:maximum => 50}
  validates :email, :presence => true, 
                    :format => {:with => email_regex}, 
                    :uniqueness => {:case_sensitive => false}
  
  validates :password, :confirmation => true,
                      :presence => true,
                      :length => { :within => 6..40 }

  before_save :encrypt_password
  
  def has_password?(sumbitted_password)
    encrypt(sumbitted_password) == encrypted_password
  end
  
  def self.authenticate(email, password)
    u = find_by_email(email)
    return nil if u.nil?
    return u if u.has_password?(password)
  end
  
  private
  
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end
  
  def encrypt(password)
    secure_hash("#{salt}--#{password}")
  end
    
  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end
  
end
