# Default security groups for the AWS project
module "default_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-default-sg"
    description = "Default security group for the AWS project"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow all inbound traffic from the VPC CIDR block"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = var.aws_vpc_config.cidr_block
        }
    ]

    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}

# Create security group for gateway, database, storage, and MLflow servers
module "gateway_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-gateway-sg"
    description = "Security group for gateway instance"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow SSH Access"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            description = "Allow HTTP Access"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            description = "Allow HTTPS Access"
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
                {
            description = "Allow OpenVPN Access"
            from_port   = 1194
            to_port     = 1194
            protocol    = "udp"
            ip          = "0.0.0.0/0"
        },
        {
            description = "Allow all traffic from servers"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = var.aws_vpc_config.cidr_block
        }
    ]

    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}

module "database_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-database-sg"
    description = "Security group for database servers"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow SSH Access"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            from_port   = 3306
            to_port     = 3306
            protocol    = "tcp"
            description = "Allow MySQL Access"
            ip          = var.aws_vpc_config.cidr_block
        },
        {
            from_port   = 27017
            to_port     = 27017
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
            description = "Allow MongoDB Access"
        },
        {
            from_port   = 6379
            to_port     = 6379
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
            description = "Allow Redis Access"
        }
    ]
    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}

module "storage_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-storage-sg"
    description = "Security group for storage servers"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow SSH Access"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            description       = "Allow all from gateway"
            from_port         = -1
            to_port           = -1
            protocol          = "-1"
            security_group_id = module.gateway_sg.id
        },
        {
            description = "Allow Harbor Access"
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
        },
        {
            description = "Allow MinIO Access"
            from_port   = 9001
            to_port     = 9001
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
        },
        {
            description = "Allow MinIO API Access"
            from_port   = 9000
            to_port     = 9000
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
        },
        {
            description = "Allow Vault Access"
            from_port   = 8200
            to_port     = 8200
            protocol    = "tcp"
            ip          = var.aws_vpc_config.cidr_block
        }
    ]
    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}

module "mlflow_sg" {
    source      = "./modules/security_group"
    name        = "${var.aws_project}-mlflow-sg"
    description = "Security group for MLflow server"
    vpc_id      = module.vpc.vpc_id

    ingress_rules = [
        {
            description = "Allow SSH Access"
            from_port   = 22
            to_port     = 22
            protocol    = "tcp"
            ip          = "0.0.0.0/0"
        },
        {
            from_port         = 5000
            to_port           = 5000
            protocol          = "tcp"
            security_group_id = module.gateway_sg.id
            description       = "Allow MLflow Server Access"
        },
        {
            from_port         = 8080
            to_port           = 8080
            protocol          = "tcp"
            security_group_id = module.gateway_sg.id
            description       = "Allow MLflow Server Web Access"
        },
        {
            from_port         = 9000
            to_port           = 9000
            protocol          = "tcp"
            security_group_id = module.gateway_sg.id
            description       = "Allow SonarQube Access"
        },
        {
            description       = "Allow all from gateway"
            from_port         = -1
            to_port           = -1
            protocol          = "-1"
            security_group_id = module.gateway_sg.id
        }
    ]
    egress_rules = [
        {
            description = "Allow all outbound traffic"
            from_port   = -1
            to_port     = -1
            protocol    = "-1"
            ip          = "0.0.0.0/0"
        }
    ]
}