# Workaround for the lack of support to create a list of N elements as list(value, N).
# When having a (different) list of N elements, another option would be to use
# formatlist(value, another_list), but for some reason the contents of the list appear
# in the resulting strings (note there is no %s in the format string).
data "template_file" "list" {
  count = var.elem_count
  template = var.value
}
