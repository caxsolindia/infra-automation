output "rds_endpoint" {
  value = aws_db_instance.edc-db.endpoint
}

output "rds_instance_id" {
  value       = aws_db_instance.edc-db.id
}

output "rds_instance_arn" {
  value       = aws_db_instance.edc-db.arn
}