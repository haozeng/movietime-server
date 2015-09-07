class PasswordsController < Devise::PasswordsController
  skip_authorization_check
  skip_load_and_authorize_resource

  respond_to :json, only: [:create]
  respond_to :html, only: [:edit, :update]

  # https://github.com/plataformatec/devise/blob/1a0192201b317d3f1bac88f5c5b4926d527b1b39/app/controllers/devise_controller.rb


  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
      else
        set_flash_message(:notice, :updated_not_active) if is_flashing_format?
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end
end