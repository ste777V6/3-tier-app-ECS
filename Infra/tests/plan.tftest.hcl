mock_provider "aws" {
  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam:us-east-1:123456789012:policy/p"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam:us-east-1:123456789012:role/r"
    }
  }
  mock_data "aws_iam_role" {
    defaults = {
      arn  = "arn:aws:iam:us-east-1:123456789012:role/ecsTaskExecutionRole"
      name = "ecsTaskExecutionRole"
    }
  }
  mock_data "aws_elb_service_account" {
    defaults = {
      arn = "arn:aws:iam::127311923021:root"
    }
  }
  mock_data "aws_region" {
    defaults = {
      region = "us-east-1"
      name   = "us-east-1"
    }
  }
  mock_resource "aws_lb" {
    defaults = {
      arn        = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/x/1"
      arn_suffix = "app/x/1"
    }
  }
  mock_resource "aws_lb_target_group" {
    defaults = {
      arn        = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/x/1"
      arn_suffix = "targetgroup/x/1"
    }
  }
  mock_resource "aws_lb_listener" {
    defaults = {
      arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:listener/app/x/1/2"
    }
  }
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn = "arn:aws:acm:us-east-1:123456789012:certificate/1"
    }
  }
  mock_resource "aws_acm_certificate_validation" {
    defaults = {
      certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/1"
    }
  }
  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-AbCdEf"
      id  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-AbCdEf"
    }
  }
  mock_resource "aws_service_discovery_http_namespace" {
    defaults = {
      arn = "arn:aws:servicediscovery:us-east-1:123456789012:namespace/ns-1"
    }
  }
  mock_resource "aws_ecs_cluster" {
    defaults = {
      arn = "arn:aws:ecs:us-east-1:123456789012:cluster/c"
      id  = "arn:aws:ecs:us-east-1:123456789012:cluster/c"
    }
  }
  mock_resource "aws_ecs_task_definition" {
    defaults = {
      arn = "arn:aws:ecs:us-east-1:123456789012:task-definition/t:1"
    }
  }
  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::b"
    }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/ecs/x"
    }
  }
}
mock_provider "random" {}

variables {
  frontend_image = "123.dkr.ecr.us-east-1.amazonaws.com/fe:abc"
  backend_image  = "123.dkr.ecr.us-east-1.amazonaws.com/be:abc"
}

run "plan" {
  command = plan

  override_module {
    target = module.alb
    outputs = {
      alb_dns_name                     = "x.elb.amazonaws.com"
      acm_validation_cname_name        = "_x"
      acm_validation_cname_value       = "_y"
      target_group_names               = { blue = "b", green = "g" }
      blue_target_group_arn            = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/b/1"
      blue_target_group_resource_label = "app/x/1/targetgroup/b/1"
    }
  }

  assert {
    condition     = output.backend_service_connect_url == "http://backend:8000"
    error_message = "backend URL wrong"
  }
}
