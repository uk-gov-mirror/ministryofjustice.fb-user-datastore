module DataObject
  class Sms
    include ActiveModel::Model

    attr_accessor :template_name, :to, :body

    def to_payload
      {
        template_name: template_name,
        to: to,
        body: body
      }
    end
  end
end
