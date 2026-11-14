variable "web_provision" {
  type        = bool
  default     = false
  description = "ansible provision switch variable"
}

resource "local_file" "hosts_templatefile" {
  content = templatefile("${path.module}/for.tftpl", {
    webservers = yandex_compute_instance.web
    databases  = yandex_compute_instance.db
    storage    = [yandex_compute_instance.storage]
  })

  filename = "${abspath(path.module)}/for.ini"
}

resource "terraform_data" "web_hosts_provision" {
  count = var.web_provision == true ? 1 : 0

  depends_on = [
    yandex_compute_instance.web,
    yandex_compute_instance.db,
    yandex_compute_instance.storage,
    local_file.hosts_templatefile
  ]

  provisioner "local-exec" {
    command    = "eval $(ssh-agent) && cat ~/.ssh/id_rsa | ssh-add -"
    on_failure = continue
  }

  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${abspath(path.module)}/for.ini ${abspath(path.module)}/test.yml"
    on_failure  = continue
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
  }

  triggers_replace = {
    template_rendered = "${local_file.hosts_templatefile.content}"
  }
}
