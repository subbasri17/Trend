-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Flow:

Developer → GitHub → Jenkins → Build → Test → Push Image → Deploy to Kubernetes
Jenkins → Docker Build → DockerHub → AWS EKS → Kubernetes Deployment → LoadBalancer → Browser
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


Step1:
Ensure below steps before deployment. 
1.Launch EC2 instance. (create a user, attach administracter access and attach that user in ec2 instances)
2.Git installed
3.Docker  installed
4. Jenkins installed. 
5.kubernaties cluster
6.Git hub and jenkins webhook connection.
7.Docker hub and AWS credentials updated on Jenkins.
8.IAM - user creation and attach required policy.
9.Git hub -below files should be present:
Dockerfile
Jenkinsfile
deployment.yaml
service.yaml
dist/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Step 1:
1. Clone git repository  ( git clone https://github.com/Vennilavanguvi/Trend.git)
2.Install docker and jenkins and kubernaties cluster, since you already placed updated file in the github.
apt-get install docker.io -y
3.jenkins : Follow the jenkins documentation and installed.
jenkins --version
ps -ef | grep jenkins
sudo systemctl status jenkins
http://43.205.137.197:8080/  - jenkins link 
4. Creating pipeline script, adding docker hub,aws credentials and  webhook setup

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Git bub:

Dockerfile
Jenkinsfile
deployment.yaml
service.yaml
dist/ 

1. Docker file 

FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY dist/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

docker run -itd -p 3000:80 imagename

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
eks-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-tasks-app
  labels:
    app: trend-tasks-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: trend-tasks-app
  template:
    metadata:
      labels:
        app: trend-tasks-app
    spec:
      containers:
        - name: webserver
          image: aarushisuba/webserver:21
          ports:
            - containerPort: 80
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

service.yaml
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
apiVersion: v1
kind: Service
metadata:
  name: trend-tasks-service
spec:
  type: LoadBalancer
  selector:
    app: trend-tasks-app
  ports:
    - port: 80
      targetPort: 80
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
Jenkins file:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Final Script:

pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "aarushisuba/webserver"
        IMAGE_TAG = "${BUILD_NUMBER}"
        AWS_REGION = "ap-south-1"
        EKS_CLUSTER = "my-eks-cluster"
    }

    stages {



        stage("Build"){
            steps {
                script {
                    sh "docker build -t webserver ."
                }
            }
        }

        stage("Login to DockerHub") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }

        stage("Tag & Push Docker Image") {
            steps {
                sh """
                docker tag webserver $DOCKERHUB_REPO:$IMAGE_TAG
                docker push $DOCKERHUB_REPO:$IMAGE_TAG
                """
            }
        }

        stage("Deploy to EKS") {
            steps {
                script {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-credentials']]) {

                    sh """
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER



                    kubectl --kubeconfig=/var/lib/jenkins/.kube/config apply -f eks-deployment.yaml
                    kubectl --kubeconfig=/var/lib/jenkins/.kube/config apply -f service.yaml
                    """
                   }
                }
            }
        }
    }
}
-------------------------------------------------------------------------------------------------------

Pushing my docker file into Github 

1. My docker file is in server
2. I am using ebelow commands to push my docker file in docker hub
1.I set my repository by using below command
git remote set-url origin https://github.com/subbasri17/Trend.git
git remote -v
git config -l
3.git add .
4.git commit -m "This is my first commit"
5.git pull origin main --rebase
6. git push origin main
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

3. Pipeline script :- Jenkins file:

Stage1: Cleanup
stage2:agents (kubernaties)
stage3:build image dockerhub push - dockerhub credentails and commands to mention.
stage4:Test 
stage5:deploy Kubernaties credentails need to mention.

---------------------------------------------------------------------------------------------------------------------------------------------------------
4. Steps:

Updating dockerhub credentials in jenkins:

Go to Jenkins → Manage Jenkins → Credentials → Global → Add Credentials

Choose Kind: Username with password

Fill in:

Username: your DockerHub username

Password: your DockerHub password (or personal access token if 2FA enabled)

ID: dockerhub-credentials (this is what your Jenkinsfile uses)

Description: DockerHub credentials for CI/CD


-----------------------------------------------------------------------------------------------------------------------------------------

5: AWS credentials configure in jenkins.
Go to Jenkins → Manage Jenkins → Credentials → Global → Add Credentials-->Choose AWS.

Need to install kubernaties,kubernaties cli,AWS credentials via plugin
Manage-credentials-aws option will show.
then select in id -you need to aws-credentials
Access key id :you get it from ( AWS --IAM -create user-Next-select 1st option--done)
you get access key and password under security.


-----------------------------------------------------------------------------------------------------------------------------------------
Before deployimg make sure steps:

1.webhook configured in both github and jenkins
2.Jenkins- update dockerhub credentials
3.Kubernaties cluster need to update in pipeline.

Installing kubernaties cluster:
------------------------------------------------------------------------------------------------------
AWS CLI/Kubernaties installation: 
------------------------------------------------------------------------------------------------------
4. sudo apt install unzip
4. then run the below commands 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
------------------------------------------------------------------------------------------------------

Need to install EKS cluster in jenkins server: 
.1. aws configure
2.access key id:
3.Password:
4.region:

2. IAM user - eks cluseter 
attach the beow policies:


AmazonEKS_CNI_Policy

AmazonVPCFullAccess

AWSCloudFormationFullAccess

AmazonEC2FullAccess

IAMFullAccess

Administrator access

run the below commands
4. sudo apt install unzip
4. then run the below commands 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
5. check aws cli is created or not 
aws s3 ls
6. then follow the belw steps:
7/curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o eksctl.tar.gz
9/tar -xzf eksctl.tar.gz
10. Move eksctl to the directory in your PATH: sudo mv eksctl /usr/local/bin

11. Verify installation: eksctl version

12. Make sure kubectl is installed: kubectl version --client

8. To install kubectl, i use below commands

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

9/ follow the steps:

https://github.com/Akshiv20/DevOps-Notes/blob/master/Kubernetes/Demo%20of%20Creating%20an%20EKS%20cluster%20using%20eksctl.txt


create EKSctl

eksctl create cluster \
  --name my-eks-cluster \
  --region ap-south-1 \
  --nodegroup-name my-eks-nodes \
  --node-type m7i-flex.large \
  --nodes 2
------------------------------------------------------------------------------------------------------

1. VPC -Route table, subnets, internet, NAt gateway cloud formation stacks.
2. Ensure :
 
Pods
Services
Deployments
ReplicaSets


kubectl get nodes
kubectl get deployment
kubectl get pods
kubectl get svc
kubectl rollout status deployment/trend-tasks-app
------------------------------------------------------------------------------------------------------


Error during deployment:

1. Error ()
permission denied while trying to connect to the Docker daemon socket

unix:///var/run/docker.sock
fix:
Add Jenkins to docker group
sudo usermod -aG docker jenkins
Restart services
sudo systemctl restart docker
sudo systemctl restart jenkins
Verify It’s Fixed
-------------------------------------------------------------------------------------------------------

sudo su - jenkins
docker ps
Check Docker socket permissions:
ls -l /var/run/docker.sock
-------------------------------------------------------------------------------------------------------

2: Error :
ERROR: Could not find credentials entry with ID 'dockerhub-credentials'

Instead of DockerHub password, use an Access Token:

Go to DockerHub

Account Settings

Security

Create Access Token

Use token as password in Jenkins

-------------------------------------------------------------------------------------------------------


error 3:

aws: [ERROR]: An error occurred (AccessDeniedException) when calling the DescribeCluster operation: User: arn:aws:iam::352232139559:user/eksuser is not authorized to perform: 
eks:DescribeCluster on resource: arn:aws:eks:ap-south-1:352232139559:cluster/my-eks-cluster because no identity-based policy allows the eks:DescribeCluster action

------------------------------------------------------------------------------------------------------------------------------

eksctl delete cluster --name my-eks-cluster --region ap-south-1

------------------------------------------------------------------------------------------------------------------------------




http://3.110.150.106:8080/

------------------------------------------------------------------------------------------------------------------------------
Promethesus:

EC2 -Prometheus agent install, config file - scrap - add application server host/9100 (port) then install grapana. open url with 3000 port. while connecting the test prometesus should open.
EC2 - APP -Node exporter install 
------------------------------------------------------------------------------------------------------------------------------
Connections:
Jenkins - Github project -project url (https://github.com/subbasri17/Trend.git/) repository name -->Triggeres---> definition-->Pipeline script from scm -->need to give repository url
branch -select main, script path --jenkins file name shpuld match.

------------------------------------------------------------------------------------------------------------------------------

