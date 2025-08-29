variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type = list(string)
  default = ["t3.small"]   
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type = number
  default = 2
}

variable "max_size" {
  type = number
  default = 6
}
