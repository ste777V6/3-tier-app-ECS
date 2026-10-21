# Seeds the quiz database ONCE with topics and questions.
#
# Runs a one-off Fargate task from the backend task definition, overriding
# its command to load seed_data.py and the CSV files baked into the image.
# Run from the Infra folder after `terraform apply` has finished:
#
#   .\scripts\seed-db.ps1
#
# Running it twice adds duplicate questions.

param(
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

$cluster = terraform output -raw ecs_cluster_name
$family  = terraform output -raw backend_task_definition_family
$subnets = (terraform output -json private_subnet_ids | ConvertFrom-Json) -join ","
$sg      = terraform output -raw backend_sg_id

# Single quotes: $f is for the container's shell, not PowerShell
$seed = 'python seed_data.py; for f in aws docker_questions jenkins_questions kubernetes_questions linux; do python bulk_upload_questions.py questions-answers/$f.csv; done'

$overrides = @{
    containerOverrides = @(
        @{ name = "backend"; command = @("sh", "-c", $seed) }
    )
} | ConvertTo-Json -Depth 5 -Compress

# ASCII avoids the UTF-8 BOM that breaks the AWS CLI's JSON parsing
$file = New-TemporaryFile
Set-Content -Path $file -Value $overrides -Encoding ascii

$taskArn = aws ecs run-task `
    --region $Region `
    --cluster $cluster `
    --launch-type FARGATE `
    --task-definition $family `
    --network-configuration "awsvpcConfiguration={subnets=[$subnets],securityGroups=[$sg],assignPublicIp=DISABLED}" `
    --overrides "file://$file" `
    --query "tasks[0].taskArn" --output text

Write-Host "Seed task started: $taskArn"
Write-Host "Waiting for it to finish (1-2 minutes)..."
aws ecs wait tasks-stopped --region $Region --cluster $cluster --tasks $taskArn

$exitCode = aws ecs describe-tasks --region $Region --cluster $cluster --tasks $taskArn `
    --query "tasks[0].containers[0].exitCode" --output text
Remove-Item $file

Write-Host "Seed task exit code: $exitCode (0 = success)"
Write-Host "Logs: aws logs tail /ecs/$family --region $Region --since 10m"
