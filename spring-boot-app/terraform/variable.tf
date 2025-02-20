variable "google_credentials_json" {
  description = "The path to the Google Cloud service account JSON credentials file."
  type        = string
  sensitive   = true  # Since this contains sensitive information, mark it as sensitive
}
