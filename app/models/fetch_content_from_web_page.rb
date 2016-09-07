class FetchContentFromWebPage
  def call(action:, on_success:, on_error:)
    response = action.call
    on_success.call(response)
  rescue Exception => exception
    error_message = build_error_message_from(exception)
    on_error.call(error_message)
  end

  private

  def build_error_message_from(exception)
    [exception.class, exception.message].join(': ')
  end
end
