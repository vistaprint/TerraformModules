output "list" {
  value = ["${data.template_file.list.*.rendered}"]
}
