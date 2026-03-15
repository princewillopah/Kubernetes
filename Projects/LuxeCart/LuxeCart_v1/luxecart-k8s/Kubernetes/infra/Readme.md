

kubectl apply -f config
kubectl apply -f infra/redis/
kubectl apply -f infra/posgres
kubectl apply -f infra/mongoDB
kubectl apply -f infra/RabbitMQ
kubectl apply -f infra/ELK_elasticsearch
kubectl apply -f infra/ELK_kibana

kubectl get po -n luxe-infra

kubectl apply -f infra/db-migrations/postgres-migrations-configmap.yaml
kubectl apply -f infra/db-migrations/postgres-migration-job.yaml
kg po,cm,job -n luxe-infra
kubectl logs job/postgres-migration -n luxe-infra
kubectl exec -it -n luxe-infra postgres-0 -- psql -U ecommerce -d ecommerce
\du
\l
\c ecommerce
\dt
SELECT * FROM users;
\q


kubectl apply -f frontend/



kubectl apply -f 
kubectl apply -f 


