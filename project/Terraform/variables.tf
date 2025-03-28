
variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {
  default = "ru-central1-a"
}
variable "token" {}
variable "ssh_public_key" {
  default = "/root/.ssh/id_ed25519.pub"
}
variable "ssh_private_key" {
  default = "/root/.ssh/id_ed25519"
}
