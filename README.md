# LEGO Set Part Prediction Project

This project builds a machine learning model to predict the number of parts in a LEGO set based on its name. The model uses text processing and a linear support vector machine (SVM) regression approach, with model versioning and API deployment facilitated by the vetiver and Plumber packages.

The application is containerized using Docker, and the Docker image can be pulled from Docker Hub for local use.

**NB:** This project draws inspiration from the Tidy Tuesday LEGO Sets dataset. It serves as a learning path for using the vetiver package to containerize R models with Docker.

## Features
* Data Source: LEGO dataset from the TidyTuesday project. 

* Model: Linear SVM regression. 

* Text Processing: TF-IDF and tokenization with the textrecipes package. 

* Model Versioning: Managed using vetiver. 

* API Deployment: Plumber API for making predictions.
* Dockerization: Image for running the API.

### How to Use the Docker Image

 1) The pre-built docker image can be pulled from Docker Hub using:
```
docker pull <your-dockerhub-username>/lego-set-names
```

2) Run the container locally using the following command:
```
docker run --rm -p 8000:8000 <your-dockerhub-username>/lego-set-names
```

This will start the API, and it will be accessible at http://127.0.0.1:8000.
