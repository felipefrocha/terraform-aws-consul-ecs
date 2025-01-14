## UNRELEASED

FEATURES
* modules/mesh-task: Run a health-sync container for essential containers when
  ECS health checks are defined and there aren't any Consul health checks
  [[GH-45](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/45)]

IMPROVEMENTS
* modules/mesh-task: Run the `consul-ecs-mesh-init` container with the
  `consul-ecs` user instead of `root`
  [[GH-52](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/52)]
* modules/mesh-task: The Consul binary is now inserted into
  `consul-ecs-mesh-init` from the `consul-client` container. This means that
  each release of `consul-ecs` will work with multiple Consul versions.
  [[GH-53](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/53)]

## 0.2.0-beta2 (Sep 30, 2021)

FEATURES
* modules/mesh-task: Add `checks` variable to define Consul native checks.
  [[GH-41](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/41)]

## 0.2.0-beta1 (Sep 16, 2021)

BREAKING CHANGES
* modules/mesh-task: `execution_role_arn` and `task_role_arn` variables have been removed.
  The mesh-task now creates those roles and instead accepts `additional_task_role_policies`
  and `additional_execution_role_policies` to modify the execution and task roles and allow
  more permissions. [[GH-19](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/19)]
* modules/mesh-task: `retry_join` is now a required variable and `consul_server_service_name`
  has been removed because we're now using AWS CloudMap to discover the dev server instead of
  the `discover-servers` container. [[GH-24](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/24)]

FEATURES
* modules/mesh-task: Enable gossip encryption for the Consul service mesh control plane. [[GH-21](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/21)]
* modules/mesh-task: Enable TLS for the Consul service mesh control plane. [[GH-19](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/19)]
* modules/acl-controller: Add new ACL controller module and enable ACLs for other components. [[GH-31](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/31)]

IMPROVEMENTS
* modules/dev-server: Use AWS CloudMap to discover the dev server instead running the `discover-servers` container.
  [[GH-24](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/24)]
* modules/mesh-task: Increase file descriptor limit for the sidecar-proxy container.
  [[GH-34](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/34)]
* Support deployments on the ECS launch type. [[GH-25](https://github.com/hashicorp/terraform-aws-consul-ecs/pull/25)]

BUG FIXES
* Use `ECS_CONTAINER_METADATA_URI_V4` url. [[GH-23](https://github.com/hashicorp/terraform-aws-consul-ecs/issues/23)]

## 0.1.1 (May 26, 2021)

IMPROVEMENTS
* Update Docker images to use docker.mirror.hashicorp.services mirror to avoid image pull errors.
* modules/mesh-task: Update to latest consul-ecs image (0.1.2).
* modules/mesh-task: Change containers running consul-ecs image to run as root so they can write
  to the shared /consul volume.
* modules/dev-server: Add variable `assign_public_ip` that is needed to run in public subnets. Defaults to `false`.

BREAKING CHANGES
* modules/dev-server: Add variable `launch_type` to select launch type Fargate or EC2.
  Defaults to `EC2` whereas previously it defaulted to `FARGATE`.

## 0.1.0 (May 24, 2021)

Initial release.
