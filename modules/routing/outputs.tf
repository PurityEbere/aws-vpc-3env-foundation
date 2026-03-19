output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "Private app route table IDs"
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_ids" {
  description = "Private DB route table IDs"
  value       = aws_route_table.private_db[*].id
}
