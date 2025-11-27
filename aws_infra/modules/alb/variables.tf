variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "ui_cert_arn" {
  type = string
}

variable "api_cert_arn" {
  type = string
}

variable "ecs_services" {
  description = "Map of ECS backend services"
  type = map(object({
    port = number
  }))
}
