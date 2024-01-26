Instructions for installing SSD in an Argo Cluster

- copy the ssd-app.yaml to your local machine
- create repo in Argo: Settings-> Repositories->Connect Repo: Add ```https://github.com/ksrinimba/enterprise-ssd```
- create SSD application from the terminal: ```kubectl apply -n argocd -f [ssd-app.yaml](https://github.com/ksrinimba/enterprise-ssd/blob/main/argo-install/ssd-app.yaml)```

Access SSD: 
- Get the admin password: ```kubectl get secret -n argocd-ssd poc-passwords -o jsonpath="{.data.ADMIN_PASSWORD}" | base64 -d``` , #copy the password 
- Port forward: ```kubectl port-forward svc/oes-ui 8080:80```
- In the browser, navigate to [http://localhost:8080](http://localhost:8080)
- username: admin , password: PASTE-THE_PASSWORD-FROM ABOVE
