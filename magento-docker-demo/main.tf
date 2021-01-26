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

resource "docker_network" "magento_network" {
  name         = "magento_network"
}
resource "docker_volume" "elasticsearch_volume" {
  name         = "elasticsearch_volume"
  driver       = "local"
}

resource "docker_image" "elasticsearch" {
  name = "bitnami/elasticsearch:6-debian-10"
}

resource "docker_image" "mariadb" {
  name = "bitnami/mariadb:10.3-debian-10"
}

resource "docker_image" "magento" {
  name = "bitnami/magento:2-debian-10"
}

resource "docker_container" "elasticsearch" {
  image = docker_image.elasticsearch.latest
  name  = "elasticsearch"
  hostname = "elasticsearch"
  network_mode = "bridge"
  volumes {
    container_path = "/bitnami/elasticsearch/data"
  }
  networks_advanced {
    name = docker_network.magento_network.name 
  }
}


resource "docker_container" "mariadb" {
  image = docker_image.mariadb.latest
  name  = "mariadb"
  hostname = "mariadb"
  network_mode = "bridge"
  env = [ "ALLOW_EMPTY_PASSWORD=yes", "MARIADB_USER=bn_magento", "MARIADB_PASSWORD=magento_db_password", "MARIADB_DATABASE=bitnami_magento"]
  volumes {
    host_path = "/apps/bitname/mariadb-persistence"
    container_path = "/bitnami"
  }
  ports {
    internal = 3306
    external = 3306
  }
  networks_advanced {
    name = docker_network.magento_network.name 
  }
}


resource "docker_container" "magento" {
  image = docker_image.magento.latest
  name  = "magento"
  network_mode = "bridge"
  hostname = "magento"
  env = [ "MARIADB_HOST=mariadb", "MARIADB_PORT_NUMBER=3306", "MAGENTO_HOST=192.168.61.130", "MAGENTO_DATABASE_USER=bn_magento", "MAGENTO_DATABASE_PASSWORD=magento_db_password", "MAGENTO_DATABASE_NAME=bitnami_magento", "ELASTICSEARCH_HOST=elasticsearch", "ELASTICSEARCH_PORT_NUMBER=9200"]
  volumes {
    host_path = "/apps/bitname/magento-persistence"
    container_path = "/bitnami"
  }
  ports {
    internal = 8080
    external = 80
  }
  ports {
    internal = 8443
    external = 443
  }
  networks_advanced {
    name = docker_network.magento_network.name 
  }
}
