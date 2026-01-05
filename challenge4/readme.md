# Challenge 04: The Resilient Python Backend
To finish Level 2, we need to move away from a single "pet" EC2 instance and toward a "cattle" approach. This challenge focuses on Scaling and Logic Integration.

Scenario: Your Python app (from Challenge 02) needs to be deployed in a highly available manner.

Task Requirements:

Infra (Bucket A): Update your Terraform to use an Auto Scaling Group (ASG) and an Application Load Balancer (ALB).

The ASG should have a min_size of 1 and max_size of 2.

The ALB should listen on port 80 and forward traffic to the ASG.

Orchestration (Bucket B):

Your user_data should now pull a Docker image.

Self-Correction/Constraint: Since we aren't using a private registry yet, you can use the user_data to build the image locally on the instance using a git clone of your app code.

Logic (Bucket C): Update your GitHub Actions workflow.

New Requirement: Add a "Linting" step for your Python code using flake8 or pylint.

The workflow should only proceed to terraform apply if the Python linting passes.


# Solution

We are required to create a terraform file which will create a Load balancer and ASG which will host minimun of 1 instance and at max 2 instances and inside the user_Data of the instances we need to write a script which will download the python script and make image out of it and start it as a container.

Below are the learning I mentioned

## main.tf

I learnt that to create lb we need to create `aws_lb`, `aws_lb_target_group` and then use `aws_lb_listener` to bind the lb with target group so that lb can forward the tarffic to according to the rules defined in listener

```tf
resource "aws_lb" "lb" {
  name               = "lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG1.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}


resource "aws_lb_target_group" "TG" {

  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health/"
  }
}


resource "aws_lb_listener" "LBListener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

```
Also I learnt that auto scaling group(ASG) needs atleast 2 subnets and it will register the instance in the target group defined above so that traffic can be routed to them. 

```tf
resource "aws_autoscaling_group" "ASG1" {
  name                = "ASG1"
  vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1


  target_group_arns = [aws_lb_target_group.TG.arn]

  launch_template {
    id = aws_launch_template.launch_template.id
  }
}
```


## workflow.yaml

Workflow.yaml file was pretty straight forward we just need to check the linting of python file and if it is correct then we can proceed futher otherwise we need to exit out of the action, for that I have changed the working directory of the action to the directory containing the pythonn code and then installed and ran the pylint command and depending upon the exit code either I am moving futher in the action or exiting it



```yaml
 - name: "linting" 
        working-directory: challenge4/python
        run: |
          pip install -r requirements.txt
          pip install pylint
          pylint app.py
          if [ $? -ne 0 ]; then
            exit 1
          fi
```

