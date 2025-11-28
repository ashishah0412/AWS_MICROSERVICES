variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "certificate_arn" {
  type    = string
  default = ""  # optional now — empty when not using ACM/HTTPS
}

variable "ecs_services" {
  description = "Map of ECS backend services"
  type = map(object({
    port = number
  }))
}
