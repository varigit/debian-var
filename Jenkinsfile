pipeline {
  agent {
    label 'linuxKernel'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '2'))
  }

  environment {
    PRODUCT_TWONAV_AVENTURA = 'twonav-aventura-2018'
    PRODUCT_TWONAV_TRAIL = 'twonav-trail-2018'
    PRODUCT_OS_AVENTURA = 'os-aventura-2018'
    PRODUCT_OS_TRAIL = 'os-trail-2018'
    TWONAV_AVENTURA_OUTPUT_DIR = 'output-twonav-aventura'
    TWONAV_TRAIL_OUTPUT_DIR = 'output-twonav-trail'
    OS_AVENTURA_OUTPUT_DIR = 'output-os-aventura'
    OS_TRAIL_OUTPUT_DIR = 'output-os-trail'
  }

  stages {
    stage('Deploy') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh "./make_var_mx6ul_dart_debian.sh -c deploy -u $USERNAME -p $PASSWORD"
        }
      }
    }

    stage('Update') {
      steps {
        withCredentials(bindings: [usernamePassword(credentialsId: 'github_credentials', 
        			usernameVariable: 'USERNAME', 
        			passwordVariable: 'PASSWORD')]) {
          sh "./make_var_mx6ul_dart_debian.sh -c update -u $USERNAME -p $PASSWORD"
        }

      }
    }

    stage('Build Kernel and package') {
      stages {
        stage('Building TwoNav Aventura') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_TWONAV_AVENTURA} -o ${WORKSPACE}/${TWONAV_AVENTURA_OUTPUT_DIR}"
          }
        }
        stage('Building TwoNav Trail') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_TWONAV_TRAIL} -o ${WORKSPACE}/${TWONAV_TRAIL_OUTPUT_DIR}"
          }
        }
        stage('Building OS Aventura') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_OS_AVENTURA} -o ${WORKSPACE}/${OS_AVENTURA_OUTPUT_DIR}"
          }
        }
        stage('Building OS Trail') {
          steps {
            sh 'sudo ./make_var_mx6ul_dart_debian.sh -c clean'
            sh "sudo ./make_var_mx6ul_dart_debian.sh -c package -t ${PRODUCT_OS_TRAIL} -o ${WORKSPACE}/${OS_TRAIL_OUTPUT_DIR}"
          }
        }
      }
    }

    stage('Fixing file permissions') {
      /* In order for ${USER} to be able to execute a script/binary using sudo without the necessity for a password,
         the following file has to be created /etc/sudoers.d/${USER} with the following contents
         ${USER} ALL = NOPASSWD: /path/to/script, /bin/chown
         listing all the commands that won't need credentials. In the above example ${USER} will be able to execure 'sudo chown'
         without beiing asked for password. 
         The following steps are necessary because Jenkins executes some commands with a user different than root on files that belong to user root,
         thus permissions have to be fixed, otherwise the pipeline fails.
      */
      steps {
        sh 'printenv'
        sh "echo ${USER}"
        sh "sudo chown -R ${USER}:${USER} rootfs"
        sh "sudo chown -R ${USER}:${USER} tmp"
        sh "sudo chown -R ${USER}:${USER} ${TWONAV_AVENTURA_OUTPUT_DIR}"
        sh "sudo chown -R ${USER}:${USER} ${TWONAV_TRAIL_OUTPUT_DIR}"
        sh "sudo chown -R ${USER}:${USER} ${OS_AVENTURA_OUTPUT_DIR}"
        sh "sudo chown -R ${USER}:${USER} ${OS_TRAIL_OUTPUT_DIR}"
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished.'
    }

    success {
      echo 'Saving Artifacts'
      archiveArtifacts artifacts: "${TWONAV_AVENTURA_OUTPUT_DIR}/*deb,${TWONAV_TRAIL_OUTPUT_DIR}/*deb,${OS_AVENTURA_OUTPUT_DIR}/*deb,${OS_TRAIL_OUTPUT_DIR}/*deb", onlyIfSuccessful: true
    }
  }
}
