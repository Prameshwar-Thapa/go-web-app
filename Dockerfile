# Use the official Golang image (version 2.24) as the base image for the first build stage
FROM golang:1.24 as base

# Set the working directory inside the container to /app
WORKDIR /app

# Copy only the go.mod file (and go.sum if it exists) to the working directory
# This is done separately to take advantage of Docker layer caching
COPY go.mod ./

# Download all dependencies specified in go.mod
RUN go mod download 

# Copy all remaining files from the host to the working directory
COPY . .

# Build the Go application and output the executable as 'main'
RUN go build -o main .

# Start a new build stage using a minimal distroless base image
# This helps reduce the final image size and attack surface
FROM gcr.io/distroless/base

# Copy the compiled 'main' executable from the first stage to this new stage
COPY --from=base /app/main .

# Copy the static files directory from the first stage to this new stage
COPY --from=base /app/static ./static

# Inform Docker that the container will listen on port 8080 at runtime
EXPOSE 9095

# Specify the command to run when the container starts (our compiled Go application)
CMD [ "./main" ]