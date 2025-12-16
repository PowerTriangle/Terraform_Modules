variable "env" {
  description = "A environment varible to add consistency to resource names."
  type        = string
  default     = "stg"
}

variable "suffix" {
  description = "A suffix to append to resource names."
  type        = string
  default     = "pipeline"
}
