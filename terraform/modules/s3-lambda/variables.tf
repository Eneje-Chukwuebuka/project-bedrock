variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "student_id" {
  description = "Student ID for unique S3 bucket naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}