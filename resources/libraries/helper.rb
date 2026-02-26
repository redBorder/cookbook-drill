module Drill
  module Helper
    def generate_random_password(len)
      chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
      key = ''
      len.times { key << chars[rand(chars.size)] }
      key
    end
  end
end
