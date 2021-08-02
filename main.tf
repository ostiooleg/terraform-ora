provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "ostioolegg_at_gmail_com" {
  name       = "olegkaragezov-ssh-key"
  public_key = var.olegkaragezov-ssh-key
}

resource "digitalocean_ssh_key" "yuriklachkovich_at_gmail_com" {
  name       = "yuriklachkovich-ssh-key"
  public_key = var.klachkovich-ssh-key
}

resource "digitalocean_ssh_key" "vladimirluksha_at_gmail_com" {
  name       = "vladimirluksha-ssh-key"
  public_key = var.luksha-ssh-key
}

resource "digitalocean_ssh_key" "mihailhodosevich_at_gmail_com" {
  name       = "mihailhodosevich-ssh-key"
  public_key = var.hodosevich-ssh-key
}

resource "digitalocean_ssh_key" "filippsebesevich_at_gmail_com" {
  name       = "filippsebesevich-ssh-key"
  public_key = var.sebesevich-ssh-key
}

resource "digitalocean_ssh_key" "romangirovka_at_gmail_com" {
  name       = "romangirovka-ssh-key"
  public_key = var.girovka-ssh-key
}


data "digitalocean_ssh_key" "ostioolegg_at_gmail_com" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Create a new tag
resource "digitalocean_tag" "ostioolegg_at_gmail_com" {
  name = "swarm"
}

resource "digitalocean_droplet" "olegkaragezov-web-1" {
  region     = "nyc1"
  image      = "ubuntu-20-04-x64"
  name       = "olegkaragezov-web-1"
  size       = "s-2vcpu-4gb"
  ssh_keys   = [data.digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.yuriklachkovich_at_gmail_com.id, digitalocean_ssh_key.vladimirluksha_at_gmail_com.id, digitalocean_ssh_key.mihailhodosevich_at_gmail_com.id, digitalocean_ssh_key.filippsebesevich_at_gmail_com.id, digitalocean_ssh_key.romangirovka_at_gmail_com.id]
  tags       = [digitalocean_tag.ostioolegg_at_gmail_com.id]

 connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_ssh_key)
    timeout = "2m"
  }

 provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install docker
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker.io",
      "service docker restart",
      "external_ip=$(hostname -I | cut -d ' ' -f 1)",
      "docker swarm init --advertise-addr $external_ip",
      "apt-get install software-properties-common",
      "add-apt-repository -y ppa:gluster/glusterfs-6",
      "apt-get update",
      "apt-get install -y glusterfs-server",
      "systemctl start glusterd",
      "docker plugin install --alias glusterfs trajano/glusterfs-volume-plugin:v2.0.3 --grant-all-permissions --disable"

    ]
  }

 provisioner "local-exec" {
    command = "ssh -i ${var.private_ssh_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${self.ipv4_address} 'docker swarm join-token -q manager' > token.txt"
  }
}

resource "digitalocean_droplet" "olegkaragezov-web-2" {
  region     = "nyc1"
  image      = "ubuntu-20-04-x64"
  name       = "olegkaragezov-web-2"
  size       = "s-2vcpu-4gb"
  ssh_keys   = [data.digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.yuriklachkovich_at_gmail_com.id, digitalocean_ssh_key.vladimirluksha_at_gmail_com.id, digitalocean_ssh_key.mihailhodosevich_at_gmail_com.id, digitalocean_ssh_key.filippsebesevich_at_gmail_com.id, digitalocean_ssh_key.romangirovka_at_gmail_com.id]
  tags       = [digitalocean_tag.ostioolegg_at_gmail_com.id]

 connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_ssh_key)
    timeout = "2m"
  }

 provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install docker
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker.io",
      "service docker restart",
      "docker swarm join --token ${trimspace(file("token.txt"))} ${digitalocean_droplet.olegkaragezov-web-1.ipv4_address}:2377",
      "apt-get install software-properties-common",
      "add-apt-repository -y ppa:gluster/glusterfs-6",
      "apt-get update",
      "apt-get install -y glusterfs-server",
      "systemctl start glusterd",
      "docker plugin install --alias glusterfs trajano/glusterfs-volume-plugin:v2.0.3 --grant-all-permissions --disable"
    ]
  }
}

resource "digitalocean_droplet" "olegkaragezov-web-3" {
  region     = "nyc1"
  image      = "ubuntu-20-04-x64"
  name       = "olegkaragezov-web-3"
  size       = "s-2vcpu-4gb"
  ssh_keys   = [data.digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.ostioolegg_at_gmail_com.id, digitalocean_ssh_key.yuriklachkovich_at_gmail_com.id, digitalocean_ssh_key.vladimirluksha_at_gmail_com.id, digitalocean_ssh_key.mihailhodosevich_at_gmail_com.id, digitalocean_ssh_key.filippsebesevich_at_gmail_com.id, digitalocean_ssh_key.romangirovka_at_gmail_com.id]
  tags       = [digitalocean_tag.ostioolegg_at_gmail_com.id]

 connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.private_ssh_key)
    timeout = "2m"
  }

 provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install docker
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update",
      "apt-get install -y docker.io",
      "service docker restart",
      "docker swarm join --token ${trimspace(file("token.txt"))} ${digitalocean_droplet.olegkaragezov-web-1.ipv4_address}:2377",
      "apt-get install software-properties-common",
      "add-apt-repository -y ppa:gluster/glusterfs-6",
      "apt-get update",
      "apt-get install -y glusterfs-server",
      "systemctl start glusterd",
      "docker plugin install --alias glusterfs trajano/glusterfs-volume-plugin:v2.0.3 --grant-all-permissions --disable"
    ]
  }
}

output "swarm_manager1_ip" {
  value = digitalocean_droplet.olegkaragezov-web-1.ipv4_address
}

output "swarm_manager2_ip" {
  value = digitalocean_droplet.olegkaragezov-web-2.ipv4_address
}

output "swarm_manager3_ip" {
  value = digitalocean_droplet.olegkaragezov-web-3.ipv4_address
}

output "swarm_manager1_private_ip" {
  value = digitalocean_droplet.olegkaragezov-web-1.ipv4_address_private
}

output "swarm_manager2_private_ip" {
  value = digitalocean_droplet.olegkaragezov-web-2.ipv4_address_private
}

output "swarm_manager3_private_ip" {
  value = digitalocean_droplet.olegkaragezov-web-3.ipv4_address_private
}