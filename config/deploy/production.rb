set :deploy_to, "/home/wucolin/apps/PMPlanner"

server 'njpmp01.sharpamericas.com', user: 'wucolin', roles: %w{app db web}, 
    ssh_options: {
      port: 22,
      keys: %w(/home/wucolin/.ssh/id_ed2551),
      forward_agent: false,
      auth_methods: %w(publickey)
    }
