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

resource "docker_network" "magento_network" {
  name         = "magento_network"
  driver       = "overlay"
 # options      = {"encrypted":"true"}
  
}

resource "docker_service" "elasticsearch" {
  name  = "elasticsearch_service"
  
  task_spec {
    networks = [docker_network.magento_network.id]
    runtime  = "container"
    container_spec {
      image = "bitnami/elasticsearch:6-debian-10"

      hostname = "elasticsearch_service"
      mounts {
        target = "/bitnami/elasticsearch/data"
        source = docker_volume.elasticsearch_volume.name
        type = "volume"
      }

    }

  }
}


resource "docker_service" "mariadb" {
  name  = "mariadb_service"
  

  task_spec {
    networks = [docker_network.magento_network.id]
    runtime  = "container"
    container_spec {
      image = "bitnami/mariadb:10.3-debian-10"

      hostname = "mariadb_service"
      mounts {
        target = "/bitnami"
        source = "/apps/bitname/mariadb-persistence"
        type = "bind"
      }

      env = {
          ALLOW_EMPTY_PASSWORD = "yes"
          MARIADB_USER = "bn_magento"
          MARIADB_PASSWORD = "magento_db_password"
          MARIADB_DATABASE = "bitnami_magento"
      }

    }

  }

  endpoint_spec {
    ports {
      target_port = "3306"
      published_port = "3306"
    }
  }

}


resource "docker_service" "magento" {
  name  = "magento_service"
  depends_on = [docker_service.elasticsearch, docker_service.mariadb]

  task_spec {
    networks = [docker_network.magento_network.id]
    runtime  = "container"
    container_spec {
      image = "bitnami/magento:2-debian-10"
      hostname = "magento_service"
      mounts {
        target = "/bitnami"
        source = "/apps/bitname/magento-persistence"
        type = "bind"
      }

      env = {
          MARIADB_HOST = "mariadb_service"
          MARIADB_PORT_NUMBER = "3306"
          MAGENTO_HOST = "192.168.61.130"
          MAGENTO_DATABASE_USER = "bn_magento"
          MAGENTO_DATABASE_PASSWORD = "magento_db_password"
          MAGENTO_DATABASE_NAME = "bitnami_magento"
          ELASTICSEARCH_HOST = "elasticsearch_service"
          ELASTICSEARCH_PORT_NUMBER = "9200"
      }
    }


  }

  endpoint_spec {
    ports {
      target_port = "8080"
      published_port = "80"
    }
    ports {
      target_port = "8443"
      published_port = "443"
    }
  }

}


#resource "docker_service" "networktool" {
#  name  = "networktool_service"
  
#  task_spec {
#    networks = [docker_network.magento_network.id]
#    runtime  = "container"
#    container_spec {
#      image = "praqma/network-multitool"

#      hostname = "networktool"

#    }

#  }
#}
