module DataObject
  class Email
    include ActiveModel::Model

    attr_accessor :template_name, :to, :subject, :body

    def to_payload
      {
        template_name: template_name,
        to: to,
        subject: subject,
        body: body
      }
    end
  end
end
