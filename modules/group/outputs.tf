# vim: tabstop=2 shiftwidth=2 expandtab
output "name" {
  description = "Name of the IAM group"
  value       = aws_iam_group.this.name
}

output "path" {
  description = "Path applied to IAM resources"
  value       = aws_iam_group.this.path
}

output "arn" {
  description = "AWS Resource Name of the created group"
  value       = aws_iam_group.this.arn
}

output "unique_id" {
  description = "Unique identifier associated with this group"
  value       = aws_iam_group.this.unique_id
}

output "policy_arns" {
  description = "Policies attached to the created group"
  value       = aws_iam_group_policy_attachment.this[*].policy_arn
}

output "inline_policy" {
  description = "JSON policy defined inline with the created group"
  value       = join("", aws_iam_group_policy.this[*].policy)
}
