module CreateUserService
  def self.call(params)
    @user_form = UserForm.new(User.new)

    if @user_form.validate(email: params[:email])
      @user_form.save
      result(success?: true, model: @user_form.model)
    elsif @user_form.errors.messages[:email] && @user_form.errors.messages[:email].size == 1  && @user_form.errors.messages[:email].first.eql?("has already been taken")
      result(success?: true, model: User.find_by(email: params[:email]))
    else
      result(success?: false, model: @user_form.model, error: "Your email is required")
    end
  end

  def self.result(options = {})
    OpenStruct.new(options)
  end
end
