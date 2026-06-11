# kubectl shortcuts for tf-project-2 devcontainer
# Sourced from ~/.bashrc via setup-shell.sh

# Core
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias ka='kubectl apply'
alias kdel='kubectl delete'
alias kc='kubectl create'
alias ke='kubectl edit'
alias kex='kubectl exec -it'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias kp='kubectl patch'
alias krun='kubectl run'

# Apply / delete from manifest
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias kcf='kubectl create -f'

# Get resources
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kubectl get pods --watch'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
alias kgsa='kubectl get sa'
alias kgns='kubectl get namespaces'
alias kgd='kubectl get deployments'
alias kgrs='kubectl get replicasets'
alias kgds='kubectl get daemonsets'
alias kgsts='kubectl get statefulsets'
alias kgpvc='kubectl get pvc'
alias kgpv='kubectl get pv'
alias kging='kubectl get ingress'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgj='kubectl get jobs'
alias kgcj='kubectl get cronjobs'
alias kgevents='kubectl get events --sort-by=.lastTimestamp'

# Describe
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kds='kubectl describe svc'
alias kdd='kubectl describe deployment'

# Context / namespace (kubectx-kubens feature)
alias kctx='kubectx'
alias kns='kubens'

# Logs / port-forward / watch
alias ktail='kubectl logs -f'
alias kpf='kubectl port-forward'
alias kgw='kubectl get --watch'

# Rollout
alias kroll='kubectl rollout'
alias krs='kubectl rollout status'
alias krr='kubectl rollout restart'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Resource usage
alias ktop='kubectl top'
alias ktopn='kubectl top nodes'
alias ktopp='kubectl top pods'

# Config / auth
alias kconf='kubectl config'
alias kconfg='kubectl config get-contexts'
alias kconfs='kubectl config set-context'
alias kauth='kubectl auth can-i'

# Node maintenance
alias kcord='kubectl cordon'
alias kuncord='kubectl uncordon'
alias kdrain='kubectl drain'

# Common output formats
alias kgpoy='kubectl get pods -o yaml'
alias kgpoj='kubectl get pods -o json'
alias kgpow='kubectl get pods -o wide'
