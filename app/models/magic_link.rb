class MagicLink < ApplicationRecord
  def mark_as_used
    update(validity: 'used')
  end

  def used?
    validity == 'used'
  end

  def expired?
    expires_at < Time.now
  end

  def valid_link?
    validity == 'valid'
  end

  def superseded?
    validity == 'superseded'
  end
end
