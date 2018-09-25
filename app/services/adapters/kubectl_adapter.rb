class Adapters::KubectlAdapter
  def self.get_secret(name)
    json = Adapters::ShellAdapter.output_of(
      kubectl_cmd(name)
    )
    Base64.decode64(
      JSON.parse(json)['data']['token']
    )
  end

  def self.kubectl_cmd(secret_name)
    [
      kubectl_binary,
      'get',
      'secret',
      secret_name,
      '-o',
      'json'
    ] + [kubectl_args]
  end

  private

  def self.kubectl_args(  context: ENV['KUBECTL_CONTEXT'],
                          bearer_token: ENV['KUBECTL_BEARER_TOKEN'],
                          namespace: ENV['KUBECTL_NAMESPACE'])
    args = []
    args << '--context=' + context unless context.blank?
    args << '--namespace=' + namespace unless namespace.blank?
    args << '--token=' + bearer_token  unless bearer_token.blank?

    args.compact.join(' ')
  end

  def self.kubectl_binary
    Adapters::ShellAdapter.output_of('which kubectl')
  end

end
