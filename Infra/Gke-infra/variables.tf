variable "region" {
  description = "The geographic region where resources will be deployed. Default is 'us-east4'."
  default     = "us-east4"
}

variable "clusterName" {
  description = "The name assigned to the Kubernetes cluster."
}

variable "diskSize" {
  description = "The size of the disk attached to each node, specified in gigabytes (GB)."
}

variable "minNode" {
  description = "The minimum number of nodes in the node pool."
}

variable "maxNode" {
  description = "The maximum number of nodes in the node pool."
}

variable "machineType" {
  description = "The type of virtual machine used for nodes, such as 'n1-standard-1' or 'e2-medium'."
}

variable "env" {
  description = "The environment for deployment, such as 'dev', 'staging', or 'production'."
  default     = ""
}

variable "company" {
  description = "The name of the company or organization using these resources."
  default     = "company-name"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet where resources will be deployed."
  default     = "10.26.3.0/24"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet where resources will be deployed."
  default     = "10.26.4.0/24"
}

variable "private_name" {
  description = "The name assigned to the private subnet."
  default     = "private"
}

variable "public_name" {
  description = "The name assigned to the public subnet."
  default     = "public"
}

variable "network_name" {
  description = "The name of the VPC network"
}

variable "project_id" {
  description = "The Google Cloud project ID where resources will be created."
}

variable "credentials_path" {
  description = "Path to the GCP credentials file"
  type        = string
}


