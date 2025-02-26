# ECR should be created automatically when a team starts a new project.  
# We can achieve this by writing a simple wrapper—for example, triggering ECR creation  
# when a GitHub repository is created.  
resource "aws_ecr_repository" "employee_registry" {
  name = "${var.environment}-employee-registry"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
}