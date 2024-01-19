# resource "helm_release" "eni-config" {
#   name       = "eni-config"
#   chart      = "eni-configs"

#   values = [
#     file("${path.module}/eni-configs/values.yaml")
#   ]
# }