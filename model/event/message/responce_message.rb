
class ResponceMessage
  def output_message(context)
    event = context.value
    text = event.message['text']

    message = MessageContext.new(DefaultMessage.new, event)

    message.output_message
  end
end