ansible_server_private_ip="<172.31.40.86>"
kubernetes_server_private_ip="<172.31.40.86>"

node{
    stage('Git checkout'){
        //replace with your github repo url
        git branch: 'main', url: 'https://github.com/emjay888/project2.git'
    }
    
     //all below sshagent variables created using Pipeline syntax
    stage('Sending Dockerfile to Ansible server'){
        sshagent(['ansible-server']) {
            sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip}"
            sh "scp /var/lib/jenkins/workspace/devops-project-one/* ubuntu@${ansible_server_private_ip}:/home/ubuntu"
        }
    }
    
    stage('Docker build image'){
        sshagent(['ansible-server']) {
         //building docker image starts
            sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} cd /home/ubuntu/"
            sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image build -t $JOB_NAME:v-$BUILD_ID ."
         //building docker image ends
         //Tagging docker image starts
            sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image tag $JOB_NAME:v-$BUILD_ID kubemubin/$JOB_NAME:v-$BUILD_ID"
         sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image tag $JOB_NAME:v-$BUILD_ID kubemubin/$JOB_NAME:latest"
         //Tagging docker image ends
        }
    }
    
    stage('push docker images to dockerhub'){
     sshagent(['ansible-server']) {
      withCredentials([string(credentialsId:'dockerhub_passwd', variable: 'dockerhub_passwd')]){
       sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker login -u kubemubin -p ${dockerhub_passwd}"
       sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image push kubemubin/$JOB_NAME:v-$BUILD_ID"
       sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image push kubemubin/$JOB_NAME:latest"
       
       //also delete old docker images
       sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} docker image rm kubemubin/$JOB_NAME:v-$BUILD_ID kubemubin/$JOB_NAME:latest $JOB_NAME:v-$BUILD_ID"
      }
        }
    }
    
    stage('Copy files from jenkins to kubernetes server'){
     sshagent(['kubernetes-server']) {
      sh "ssh -o StrictHostKeyChecking=no ubuntu@${kubernetes_server_private_ip} cd /home/ubuntu/"
      sh "scp /var/lib/jenkins/workspace/devops-project-one/* ubuntu@${kubernetes_server_private_ip}:/home/ubuntu"
     }
    }
 
    stage('Kubernetes deployment using ansible'){
     sshagent(['ansible-server']) {
      sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} cd /home/ubuntu/"
      sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} ansible -m ping ${kubernetes_server_private_ip}"
      sh "ssh -o StrictHostKeyChecking=no ubuntu@${ansible_server_private_ip} ansible-playbook ansible-playbook.yml"
     } 
    }
 
}
