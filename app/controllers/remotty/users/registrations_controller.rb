class Remotty::Users::RegistrationsController < Devise::RegistrationsController
  wrap_parameters :user, include: [:email, :name, :password, :password_confirmation, :current_password]

  # POST /resource
  # 회원가입
  def create
    build_resource(sign_up_params)
    resource.use_password = true

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)

        token = resource.generate_auth_token!('web', request.remote_ip)

        render json: resource.with_token(token)
      else
        expire_data_after_sign_in!

        render_error 'UNAUTHORIZED',
                     find_message("signed_up_but_#{resource.inactive_message}"),
                     :unauthorized
      end
    else
      clean_up_passwords resource

      render_error 'VALIDATION_ERROR',
                   resource.errors.full_messages.first
    end
  end

  # PUT /resource
  # 회원정보 수정 (password 제외한 일반 정보)
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if account_update_params[:password].blank? # password 수정이 아니면
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")

      if resource.update_without_password(account_update_params)
        yield resource if block_given?

        message_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated

        sign_in resource_name, resource, :bypass => true, :store => false

        if message_key == :updated
          render json: resource
        else
          render_error 'UNAUTHORIZED',
                       find_message(message_key),
                       :unauthorized
        end
      else
        clean_up_passwords resource

        render_error 'VALIDATION_ERROR',
                     resource.errors.full_messages.first
      end
    else # password 수정이면
      if resource.use_password
        resource.update_with_password(account_update_params)
      else
        resource.use_password = true
        resource.update_attributes(account_update_params)
        clean_up_passwords resource
      end

      if resource.errors.blank?
        render json: resource
      else
        render_error 'VALIDATION_ERROR',
                     resource.errors.full_messages.first
      end
    end
  end

  # DELETE /resource
  # 회원탈퇴
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    render nothing: true, status: :no_content
  end
end
