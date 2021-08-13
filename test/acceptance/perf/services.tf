resource "aws_ecs_service" "test_server" {
  name            = "${local.name}-test-server"
  cluster         = aws_ecs_cluster.this.arn
  task_definition = module.test_server.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets = module.vpc.private_subnets
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true

  tags = var.tags
}

module "test_server" {
  source = "../../../modules/mesh-task"
  family = "${local.name}-test-server"
  container_definitions = [{
    name      = "basic"
    image     = "ghcr.io/lkysow/fake-service:v0.21.0"
    essential = true
    },
  ]
  datadog_api_key = var.datadog_api_key
  retry_join      = "provider=aws region=${var.region} tag_key=${local.name} tag_value=${local.name}"
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "${local.name}-test-server"
    }
  }
  port                          = 9090
  additional_task_role_policies = [aws_iam_policy.consul_retry_join.arn]

  tls                       = true
  consul_server_ca_cert_arn = aws_secretsmanager_secret.ca_cert.arn
  gossip_key_secret_arn     = aws_secretsmanager_secret.gossip_key.arn
}

resource "aws_ecs_service" "load_client" {
  name            = "${local.name}-load-client"
  cluster         = aws_ecs_cluster.this.arn
  task_definition = module.load_client.task_definition_arn
  desired_count   = 1
  network_configuration {
    subnets = module.vpc.private_subnets
  }
  launch_type            = "FARGATE"
  propagate_tags         = "TASK_DEFINITION"
  enable_execute_command = true

  tags = var.tags
}

module "load_client" {
  source = "../../../modules/mesh-task"
  family = "${local.name}-load-client"
  container_definitions = [{
    name      = "load"
    image     = "buoyantio/slow_cooker"
    essential = true
    command = [
      "-qps", "1000",
      "-concurrency", "16",
      "-metric-addr","0.0.0.0:9102",
      "http://127.0.0.1:1234",
    ]
    linuxParameters = {
      initProcessEnabled = true
    }
  }]
  datadog_api_key = var.datadog_api_key
  additional_task_role_policies = [aws_iam_policy.consul_retry_join.arn]
  retry_join      = "provider=aws region=${var.region} tag_key=${local.name} tag_value=${local.name}"
  upstreams = [
    {
      destination_name = "${local.name}-test-server"
      local_bind_port  = 1234
    }
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group         = aws_cloudwatch_log_group.log_group.name
      awslogs-region        = var.region
      awslogs-stream-prefix = "${local.name}-load-client"
    }
  }
  outbound_only = true

  tls                       = true
  consul_server_ca_cert_arn = aws_secretsmanager_secret.ca_cert.arn
  gossip_key_secret_arn     = aws_secretsmanager_secret.gossip_key.arn
}