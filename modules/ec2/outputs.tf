output "servers_id" {
  value = aws_instance.server.*.id
}