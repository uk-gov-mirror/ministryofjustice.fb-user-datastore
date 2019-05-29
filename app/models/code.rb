class Code < ApplicationRecord
  after_initialize :generate_code

  def mark_as_used
    update(validity: 'used')
  end

  def used?
    validity == 'used'
  end

  def superseded?
    validity == 'superseded'
  end

  def expired?
    expires_at < Time.now
  end

  def valid_code?
    validity == 'valid'
  end

  private

  def generate_code
    self.code ||= rand(89999) + 10000
  end
end
