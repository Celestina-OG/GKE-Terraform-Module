variable "project" {
  description = "The Google Cloud project ID where resources will be created."
}

variable "env" {
  description = "The environment for deployment, such as 'dev', 'staging', or 'production'."
}

variable "company" { 
  description = "The name of the company or organization using these resources."
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet where resources will be deployed."
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet where resources will be deployed."
}

variable "private_name" {
  description = "The name assigned to the private subnet."
}

variable "public_name" {
  description = "The name assigned to the public subnet."
}

variable "region" {
  description = "The geographic region where resources will be deployed. Default is 'us-east4'."
}