- Documentation on how to build and run the application locally 
- Application source code 
- Unit tests for testing the application

Business Requirements – Cloud positions
- The Application must serve variable amount of traffic. Most users are active during business
hours. During big events and conferences, the traffic could be significantly higher than
typically.
- There should be a guarantee to preserve notes up to 3 years and recover them if needed.
- Ensure continuity in service in case of datacentre failures.
- The service must be capable of being migrated/redeployed to any of the regions supported
by the cloud provider in case of a complete regional failure.
- The client is planning to use more than 100 developers to work in this project who want to
roll out multiple deployments a day without interruption / downtime.
- The client wants to provision separated environments to support their process for
development, testing and production soon. Separation of different environments is a must.
- The client expects to see relevant metrics and logs from the infrastructure for quality
assurance and security purposes.

Application must be scalable - horizontal scaling and vertical scaling.
Housekeeping - notes upto 3 years 
Business continuity - dc failures - deployed in multiple azs
Move to region of choice
Multiple deployments with no downtime - Deployment strategy
Seperate environments
Monitoring and alerting

Business Requirements - Kubernetes positions
- the application can be deployed in a Multi-cloud/Hybrid environment
- Ensure the application is using best security practices.
- Ensure your design focuses on application build and containerisation security best practices

TEmplate and terraform
Security practices ?
application and containerisation security practice - rbac

Outputs
- Documentation, presentation demonstrating the benefits of the designed, chosen solution.
- Source code produced to create the environments, infrastructure in an organised way.
- Optionally, a working solution of deploying Notejam and its components.



