output "namespace_name" {
 
  value       = kubernetes_namespace.ns.metadata[0].name
}

output "namespace_uid" {
  
  value       = kubernetes_namespace.ns.metadata[0].uid
}