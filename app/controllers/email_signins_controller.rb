class EmailSigninsController < ApplicationController
  def add
    supersede_existing_records

    magic_link = MagicLink.new(service_slug: params[:service_slug],
                               encrypted_email: params[:encrypted_email],
                               expires_at: expires_at)

    if magic_link.save
      render json: { token: magic_link.id }, status: :created
    end
  end

  def validate
    magic_link = MagicLink.find_by(service_slug: params[:service_slug],
                                   id: params[:magiclink])

    return render_magic_link_missing_error unless magic_link
    return render_magic_link_used_error if magic_link.used?
    return render_magic_link_expired_error if magic_link.expired?
    return render_magic_link_superseded if magic_link.superseded?
    return render_magic_link_invalid_error unless magic_link.valid_link?

    magic_link.mark_as_used

    save_return = SaveReturn.find_by(service_slug: magic_link.service_slug,
                                     encrypted_email: magic_link.encrypted_email)

    return render_save_and_return_missing_error unless save_return

    return render json: { encrypted_details: save_return.encrypted_payload }, status: :ok
  end

  private

  def expires_at
    Time.now + 24.hours
  end

  def supersede_existing_records
    magic_links = MagicLink.where(service_slug: params[:service_slug],
                                  encrypted_email: params[:encrypted_email])

    magic_links.update_all(validity: 'superseded')
  end

  def render_magic_link_missing_error
    render json: { code: 401,
                   name: 'token.invalid' }, status: 401
  end

  def render_magic_link_superseded
    render json: { code: 401,
                   name: 'token.superseded' }, status: 401
  end

  def render_magic_link_invalid_error
    render json: { code: 401,
                   name: 'token.invalid' }, status: 401
  end

  def render_magic_link_used_error
    render json: { code: 401,
                   name: 'token.used' }, status: 401
  end

  def render_magic_link_expired_error
    render json: { code: 401,
                   name: 'token.expired' }, status: 401
  end

  def render_save_and_return_missing_error
    render json: { code: 401,
                   name: 'token.invalid' }, status: 401
  end
end
