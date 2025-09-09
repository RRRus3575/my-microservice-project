pipeline {
      agent {
        kubernetes {
          label 'kaniko'
          defaultContainer 'jnlp'
          yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: default
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/sh
    args:
    - -c
    - cat
    tty: true
    env:
    - name: AWS_DEFAULT_REGION
      valueFrom:
        secretKeyRef:
          name: aws-creds
          key: region
    - name: AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: aws-creds
          key: access_key_id
    - name: AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: aws-creds
          key: secret_access_key
    volumeMounts:
    - name: kaniko-secret
      mountPath: /kaniko/.docker
  volumes:
  - name: kaniko-secret
    secret:
      secretName: docker-config
          """
        }
      }
      environment {
        ECR_REGISTRY = "${ECR_URL}"      
        IMAGE_NAME  = "django-app"
        HELM_REPO_URL = "${HELM_REPO_URL}" 
        HELM_REPO_CRED = 'helm-git-cred'   
        CHART_PATH = "charts/django-app/values.yaml"
      }
      options { timestamps() }
      stages {
        stage('Checkout') {
          steps { checkout scm }
        }
        stage('Build & Push Image (Kaniko)') {
          steps {
            container('kaniko') {
              script {
                def tag = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                sh """
                  /kaniko/executor                     --context `pwd`                     --dockerfile Dockerfile                     --destination $ECR_REGISTRY/$IMAGE_NAME:${tag}                     --destination $ECR_REGISTRY/$IMAGE_NAME:build-${BUILD_NUMBER}                     --single-snapshot
                """
                env.NEW_TAG = tag
              }
            }
          }
        }
        stage('Update Helm Chart tag') {
          steps {
            dir('helm-repo') {
              git url: "${HELM_REPO_URL}", branch: 'main', credentialsId: "${HELM_REPO_CRED}"
              sh """
                yq -i '.image.tag = strenv(NEW_TAG)' ${CHART_PATH}
                git config user.email "ci@example.com"
                git config user.name "jenkins-bot"
                git add ${CHART_PATH}
                git commit -m "ci: bump image tag to ${NEW_TAG} [skip ci]" || echo "No changes"
                git push origin main
              """
            }
          }
        }
      }
      post {
        success {
          echo "Image pushed and Helm chart updated to tag: ${env.NEW_TAG}. Argo CD should auto-sync."
        }
      }
    }
