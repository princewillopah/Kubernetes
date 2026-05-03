✅ How to deploy
KIND
    helm install luxecart ./luxecart -f values.yaml -f values-kind.yaml
EKS
    helm install luxecart ./luxecart -f values.yaml -f values-eks.yaml