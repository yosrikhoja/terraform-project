output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "load_balancer_dns" {
  value = aws_lb.app_lb.dns_name
}
output "lb_dns_name" {
  value = aws_lb.app.dns_name
}