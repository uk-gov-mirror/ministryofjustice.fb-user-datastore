class KubectlAdapter
  def self.get_secret(name)
    json = ShellAdapter.output_of(
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
    ] + kubectl_args
  end

  private

  def self.kubectl_args(  context: ENV['KUBECTL_CONTEXT'],
                          bearer_token: ENV['KUBECTL_BEARER_TOKEN'],
                          namespace: )
    [
        '--context=' + context,
        '--namespace=' + namespace,
        '--token=' + bearer_token
    ]
  end

  def self.kubectl_binary
    ShellAdapter.output_of('which kubectl')
  end

end
