# DevOps Lab: CI/CD Pipeline with Git, Jenkins, Maven & Docker

This project is a complete, working scaffold for the assignment. It includes:
- A Java Maven app with a unit-tested `Calculator` class
- A multi-stage `Dockerfile`
- A `Jenkinsfile` defining the full pipeline
- Instructions below for GitHub, Jenkins, and Docker setup

## Project structure
```
devops-cicd-lab/
├── pom.xml
├── Dockerfile
├── Jenkinsfile
├── README.md
└── src
    ├── main/java/com/example/app/
    │   ├── App.java
    │   └── Calculator.java
    └── test/java/com/example/app/
        └── CalculatorTest.java
```

## Step 1: Test the app locally (optional, needs Java 17 + Maven installed)
```bash
mvn clean test        # run unit tests
mvn clean package      # build the jar → target/devops-cicd-lab.jar
java -jar target/devops-cicd-lab.jar
```

## Step 2: Push to GitHub
```bash
cd devops-cicd-lab
git init
git add .
git commit -m "Initial commit: Maven app with tests, Dockerfile, Jenkinsfile"
git branch -M main
git remote add origin https://github.com/<your-username>/devops-cicd-lab.git
git push -u origin main
```

## Step 3: Set up Jenkins
1. **Install Jenkins** (if not already):
   ```bash
   docker run -d --name jenkins \
     -p 8080:8080 -p 50000:50000 \
     -v jenkins_home:/var/jenkins_home \
     -v /var/run/docker.sock:/var/run/docker.sock \
     jenkins/jenkins:lts
   ```
   Mounting `docker.sock` lets Jenkins run `docker build`/`docker run` commands on the host engine.

2. **Unlock Jenkins**: get the initial password with
   `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

3. **Install plugins**: Git, Pipeline, Docker Pipeline, JUnit, Maven Integration.

4. **Configure Maven**: Manage Jenkins → Tools → Maven installations → add one named `Maven3` (must match the `tools` block in the `Jenkinsfile`).

5. **Add Docker Hub credentials**: Manage Jenkins → Credentials → add a "Username with password" credential with ID `dockerhub-creds` (matches the `Jenkinsfile`).

6. **Create the pipeline job**:
   - New Item → Pipeline → name it `devops-cicd-lab`
   - Pipeline → Definition: "Pipeline script from SCM"
   - SCM: Git → repository URL: your GitHub repo → branch: `main` → script path: `Jenkinsfile`

7. Before running, edit the `Jenkinsfile` in your repo:
   - Replace `yourusername/devops-cicd-lab.git` with your actual GitHub URL
   - Replace `yourdockerhubusername/devops-cicd-lab` with your actual Docker Hub repo name

## Step 4: Run the pipeline
Click **Build Now**. The pipeline will:
1. Checkout code from GitHub
2. Compile with Maven
3. Run JUnit tests (results published in Jenkins)
4. Package the jar
5. Build a Docker image from the `Dockerfile`
6. Push the image to Docker Hub
7. Deploy it as a running container on port 8080

## Step 5: Verify the deployment
```bash
docker ps                      # confirm devops-cicd-lab-container is running
docker logs devops-cicd-lab-container
```
You should see the calculator output and "App is running inside the container successfully."

## Manual Docker commands (without Jenkins, for testing)
```bash
docker build -t devops-cicd-lab:latest .
docker run -d --name devops-cicd-lab-container -p 8080:8080 devops-cicd-lab:latest
docker logs devops-cicd-lab-container
```

## Notes for the assignment write-up
- Mention that `maven-surefire-plugin` runs tests during `mvn test`, and Jenkins publishes results via the `junit` step reading `target/surefire-reports/*.xml`.
- The Dockerfile uses a **multi-stage build**: stage 1 compiles with a full Maven+JDK image, stage 2 copies only the final jar into a slim JRE image — keeping the final image small.
- Screenshot checklist typically expected by graders: GitHub repo, Jenkins job configuration, a successful pipeline run (all stages green), `docker images` showing the built image, and `docker ps`/`docker logs` showing the running container.
