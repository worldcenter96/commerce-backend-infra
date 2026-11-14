variable "zone" {
  description = "Route 53 Public Hosted Zone"
  type = object({
    name     = string
    tag_name = string
  })
}

variable "certificate" {
  description = "ACM 인증서"
  type = object({
    name                      = string
    domain_name               = string
    subject_alternative_names = list(string)
    validation_method         = string
  })
}
