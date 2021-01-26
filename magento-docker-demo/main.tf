terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.11.0"
    }
  }
}

provider "docker" {
}

resource "docker_volume" "elasticsearch_volume" {
  name         = "elasticsearch_volume"
  driver       = "local"
}

resource "docker_image" "elasticsearch" {
  name = "bitnami/elasticsearch:6-debian-10"
}

resource "docker_container" "elasticsearch" {
  image = docker_image.elasticsearch.latest
  name  = "elasticsearch"
  volumes {
    volume_name = docker_volume.elasticsearch_volume.name
    container_path = "/bitnami/elasticsearch/data"
  }
}

