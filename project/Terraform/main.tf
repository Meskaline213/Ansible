
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.138.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket     = "skillfactory-bucket"
    region     = "ru-central1"
    key        = "issue1/lb.tfstate"
    access_key = "se key"
    secret_key = "se key"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "default" {
  name = "default-network"
}

resource "yandex_vpc_subnet" "default" {
  name           = "default-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

data "yandex_compute_image" "centos" {
  family = "centos-stream-8"
}

# VM1 с Ansible
resource "yandex_compute_instance" "vm1" {
  name = "vm1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y ansible"
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }
  }
}

# VM2 и VM3
resource "yandex_compute_instance" "vms" {
  count = 2
  name  = "vm${count.index + 2}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = count.index == 0 ? data.yandex_compute_image.ubuntu.image_id : data.yandex_compute_image.centos.image_id
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }
}
