pipeline {

	agent any
	
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Git-Release') {
            steps {
              withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'github-api-personal', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                  sh '/var/jenkins_home/workspace/simple-java-maven-app/jenkins/scripts/create-github-release-with-asset.sh user=$USERNAME token=$PASSWORD'
              }
            }
        }
        stage('Deliver') {
            steps {
                sh 'mvn jar:jar install:install help:evaluate -Dexpression=project.name'
            }
        }
    }
      
}
