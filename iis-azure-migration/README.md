# IIS modernization prototype

This prototype packages a small static IIS workload as a Windows container.

## Build

Run these commands from this directory on a Windows host with Docker configured for Windows containers:

```powershell
docker build -t legacy-status .
docker run --name legacy-status-web --publish 8080:80 --detach legacy-status
```

## Verify

```powershell
$response = Invoke-WebRequest -Uri http://localhost:8080/
$response.StatusCode
$response.Content -match 'LegacyStatus is online'
```

The expected checks are an HTTP 200 status and `True` for the content marker.

## Clean up

```powershell
docker stop legacy-status-web
docker rm legacy-status-web
```

The Dockerfile contains no secrets or environment-specific bindings. A production deployment should provide those through the selected hosting platform's configuration.
