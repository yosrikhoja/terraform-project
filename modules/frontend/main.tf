# modules/frontend/main.tf
resource "aws_lb" "alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
}

resource "aws_route53_record" "dns" {
  zone_id = var.hosted_zone_id
  name    = "example.com"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}