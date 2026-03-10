output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "security_group_id" {
  value = aws_security_group.ecs_sg.id
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}