set :deploy_to, "/home/wucolin/src/PMPlanner"

server 'njpmq01.sharpamericas.com', user: 'wucolin', roles: %w{app db}, 
    ssh_options: {
      port: 22,
      keys: %w(/home/wucolin/.ssh/id_rsa),
      forward_agent: false,
      auth_methods: %w(publickey)
    }
