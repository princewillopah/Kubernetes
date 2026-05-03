namespace: luxe-backend

global:
  environment: dev


defaults:
  imagePullPolicy: Always

  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 256Mi

  readinessProbe:
    path: /health
    initialDelaySeconds: 40
    periodSeconds: 30
    timeoutSeconds: 25
    failureThreshold: 15

  livenessProbe:
    path: /health
    initialDelaySeconds: 40
    periodSeconds: 30
    timeoutSeconds: 25
    failureThreshold: 15


services:
  # Admin Service
  admin-service:
    imagePullPolicy: Always
    port: 3010
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
    
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic

  # API Gateway Service
  api-gateway-service:
    imagePullPolicy: Always
    port: 3000
    env:
      - name: JWT_SECRET
        valueFrom:
          secretKeyRef:
            name: jwt-auth-secret
            key: JWT_SECRET
      - name: REDIS_URL
        valueFrom:
          secretKeyRef:
            name: redis-connection
            key: REDIS_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    envFrom:
      - configMapRef: api-gateway-config

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # Analytics Service
  analytics-service:
      imagePullPolicy: Always
      port: 3013
      env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: postgres-connection
              key: DATABASE_URL

      resources:
        requests:
          cpu: 50m
          memory: 128Mi
        limits:
          cpu: 100m
          memory: 256Mi

      readinessProbe:
        path: /health
        initialDelaySeconds: 40
        periodSeconds: 30
        timeoutSeconds: 25
        failureThreshold: 15

      livenessProbe:
        path: /health
        initialDelaySeconds: 40
        periodSeconds: 30
        timeoutSeconds: 25
        failureThreshold: 15
      
      # service configuration
      portName: metrics
      serviceType: ClusterIP
      labels:
        tier: business-logic



  # Auth Service
  auth-service:
    imagePullPolicy: Always
    port: 3001
    env:
      - name: JWT_SECRET
        valueFrom:
          secretKeyRef:
            name: jwt-auth-secret
            key: JWT_SECRET
      - name: REDIS_URL
        valueFrom:
          secretKeyRef:
            name: redis-connection
            key: REDIS_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic



  # Cart Service
  cart-service:
    imagePullPolicy: Always
    port: 3004
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: REDIS_URL
        valueFrom:
          secretKeyRef:
            name: redis-connection
            key: REDIS_URL

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # Email Service
  email-service:
    imagePullPolicy: Always
    port: 3015
    env:
      - name: PORT
        value: "3015"
      - name: SMTP_HOST
        value: "smtp.gmail.com"
      - name: SMTP_PORT
        value: "587"
      - name: SMTP_USER
        valueFrom:
          secretKeyRef:
            name: email-secrets
            key: SMTP_USER
      - name: SMTP_PASSWORD
        valueFrom:
          secretKeyRef:
            name: email-secrets
            key: SMTP_PASSWORD
      - name: FROM_EMAIL
        valueFrom:
          secretKeyRef:
            name: email-secrets
            key: FROM_EMAIL
      - name: MONGODB_URL
        valueFrom:
          secretKeyRef:
            name: mongodb-connection
            key: MONGODB_URL
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # Inventory Service
  inventory-service:
    port: 3011
    imagePullPolicy: Always
    env:
      - name: LOW_STOCK_THRESHOLD
        value: "10"
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi

    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # Notification Service
  notification-service:
    imagePullPolicy: Always
    port: 3009
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # order-service:
  order-service:
    imagePullPolicy: Always
    port: 3005
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic

  # Payment Service
  payment-service:
    imagePullPolicy: Always
    port: 3008
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic



  # product-service:
  product-service:
    imagePullPolicy: Always
    port: 3003
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: REDIS_URL
        valueFrom:
          secretKeyRef:
            name: redis-connection
            key: REDIS_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # rating-service:
  rating-service:
    imagePullPolicy: Always
    port: 3007
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # recommendation-service:
  recommendation-service:
    imagePullPolicy: Always
    port: 3014
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: REDIS_URL
        valueFrom:
          secretKeyRef:
            name: redis-connection
            key: REDIS_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic

  # review-service:
  review-service:
    imagePullPolicy: Always
    port: 3006
    env:
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic

  # Search Service
  search-service:
    imagePullPolicy: Always
    port: 3012
    env:
      - name: ELASTICSEARCH_URL
        valueFrom:
          secretKeyRef:
            name: elasticsearch-connection
            key: ELASTICSEARCH_URL
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic


  # User Service
  user-service:
    imagePullPolicy: Always
    port: 3002
    env:
      - name: JWT_SECRET
        valueFrom:
          secretKeyRef:
            name: jwt-auth-secret
            key: JWT_SECRET
      - name: DATABASE_URL
        valueFrom:
          secretKeyRef:
            name: postgres-connection
            key: DATABASE_URL
      - name: RABBITMQ_URL
        valueFrom:
          secretKeyRef:
            name: rabbitmq-connection
            key: RABBITMQ_URL
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 100m
        memory: 256Mi
    readinessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15

    livenessProbe:
      path: /health
      initialDelaySeconds: 40
      periodSeconds: 30
      timeoutSeconds: 25
      failureThreshold: 15
      
    # service configuration
    portName: metrics
    serviceType: ClusterIP
    labels:
      tier: business-logic





ingress:
  enabled: false

hpa:
  enabled: false

pdb:
  enabled: false

serviceAccount:
  create: true
  name: ""
