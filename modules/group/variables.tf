# vim: tabstop=2 shiftwidth=2 expandtab
variable "name" {
  description = "AWS IAM group name"
  type        = string
}

variable "path" {
  description = "IAM path associated with this group."
  type        = string
  default     = "/"
}

variable "policy_arns" {
  description = "Policies to attach to this group"
  type        = list(string)
  default     = []
}

variable "policy" {
  description = "Inline JSON policy for this group."
  type        = string
  default     = ""

  validation {
    condition     = var.policy == "" ? true : can(jsondecode(var.policy))
    error_message = "Invalid string data format for var.policy (must be JSON)."
  }
}
