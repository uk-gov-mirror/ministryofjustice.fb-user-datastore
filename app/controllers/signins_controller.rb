class SigninsController < ApplicationController
  def email
    supersede_existing_records

    magic_link = MagicLink.new(service_slug: params[:service_slug],
                               email: params[:email],
                               encrypted_email: params[:encrypted_email],
                               validation_url: params[:validation_url],
                               expires_at: expires_at)

    if magic_link.save
      magic_link.send_magic_link_email
      render json: {}
    end
  end

  def magic_link
    magic_link = MagicLink.find_by(service_slug: params[:service_slug],
                                   id: params[:magiclink])

    return render_magic_link_missing_error unless magic_link
    return render_magic_link_used_error if magic_link.used?
    return render_magic_link_expired_error if magic_link.expired?

    magic_link.mark_as_used

    save_return = SaveReturn.find_by(service_slug: magic_link.service_slug,
                                     encrypted_email: magic_link.encrypted_email)

    return render_save_and_return_missing_error unless save_return

    return render json: { encrypted_details: save_return.encrypted_payload }
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
    render json: { code: 404,
                   name: 'invalid.link' }, status: 404
  end

  def render_magic_link_used_error
    render json: { code: 400,
                   name: 'used.link' }, status: 400
  end

  def render_magic_link_expired_error
    render json: { code: 400,
                   name: 'expired.link' }, status: 400
  end

  def render_save_and_return_missing_error
    render json: { code: 500,
                   name: 'missing.savereturn' }, status: 500
  end
end
