# Terraform - AWS Dual Instance Deployment

This repository contains Terraform configuration files to deploy two AWS EC2 instances in two different availability zones (us-east-1a, us-east-1b). Both instances are balanced by a network load balancer. In addition a bash script is included to set up a Nginx web server listening to port 80 with a custom index page including the instance’s hostname.

The configuration will automatically update your ssh config file with the information of the EC2 instances to simplify developer access to the instances.

### Prerequisites

Requirements for the software and other tools to build, test and push

- Ubuntu 20.04 or any compatible os.
- An AWS account with full EC2/VPC permissions.
- A Terraform version compatible with Terraform v1.2.8.

## Installing

You can either deploy the AWS instances and configure the web server separately, or you can use the included user_data argument to have the servers instantiated and serving all at once.

### Ready-to-serve installation

clone/download this repository

    ```git clone git@github.com:ferivb/Terraform_aws_ec2-nlb.git```

Open main.tf with your preferred text editor and uncomment line 100

    ```code main.tf```

Initialize Terraform

    ```terraform init```

Apply the terraform configuration

    ```terraform apply -auto-approve```

### Stand-alone installation

clone/download this repository

    ```git clone git@github.com:ferivb/Terraform_aws_ec2-nlb.git```

Initialize Terraform

    ```terraform init```

Apply the terraform configuration

    ```terraform apply -auto-approve```

Secure copy the nginx-installer.sh script into each of the EC2 instances

    ```scp nginx-installer.sh ubuntu@[instance ip]:~```

Ssh into the instance and execute the script

    ```ssh [instance ip]

    ./nginx-installer.sh```

## Running the tests

Explain how to run the automated tests for this system

### Sample Tests

Explain what these tests test and why

    Give an example

### Style test

Checks if the best practices and the right coding style has been used.

    Give an example

## Deployment

Add additional notes to deploy this on a live system

## Built With

- [Contributor Covenant](https://www.contributor-covenant.org/) - Used
  for the Code of Conduct
- [Creative Commons](https://creativecommons.org/) - Used to choose
  the license

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code
of conduct, and the process for submitting pull requests to us.

## Versioning

We use [Semantic Versioning](http://semver.org/) for versioning. For the versions
available, see the [tags on this
repository](https://github.com/PurpleBooth/a-good-readme-template/tags).

## Authors

- **Billie Thompson** - _Provided README Template_ -
  [PurpleBooth](https://github.com/PurpleBooth)

See also the list of
[contributors](https://github.com/PurpleBooth/a-good-readme-template/contributors)
who participated in this project.

## License

This project is licensed under the [CC0 1.0 Universal](LICENSE.md)
Creative Commons License - see the [LICENSE.md](LICENSE.md) file for
details

## Acknowledgments

- Hat tip to anyone whose code is used
- Inspiration
- etc
