package kubernetes.pod_security

import rego.v1

deny contains msg if {
	input.kind == "Deployment"
	not input.spec.template.spec.securityContext.runAsNonRoot
	msg := sprintf("Deployment '%s' must set spec.template.spec.securityContext.runAsNonRoot to true", [input.metadata.name])
}

deny contains msg if {
	input.kind == "Deployment"
	some container in input.spec.template.spec.containers
	not _has_resource_bounds(container)
	msg := sprintf("Deployment '%s' container '%s' must define CPU and memory requests and limits", [input.metadata.name, container.name])
}

deny contains msg if {
	input.kind == "Deployment"
	input.environment == "prod"
	replicas := object.get(input.spec, "replicas", 1)
	replicas < 2
	msg := sprintf("Production Deployment '%s' must run at least 2 replicas (found %d)", [input.metadata.name, replicas])
}

deny contains msg if {
	input.kind == "Deployment"
	input.environment == "prod"
	some container in input.spec.template.spec.containers
	not contains(container.image, "@sha256:")
	msg := sprintf("Production Deployment '%s' container '%s' must reference an immutable image digest (@sha256:...): %s", [input.metadata.name, container.name, container.image])
}

deny contains msg if {
	input.kind == "Deployment"
	input.environment == "prod"
	some container in input.spec.template.spec.containers
	pull_policy := object.get(container, "imagePullPolicy", "")
	pull_policy != "Always"
	msg := sprintf("Production Deployment '%s' container '%s' must set imagePullPolicy to Always", [input.metadata.name, container.name])
}

_has_resource_bounds(container) if {
	res := object.get(container, "resources", {})
	reqs := object.get(res, "requests", {})
	lims := object.get(res, "limits", {})
	reqs.cpu != null
	reqs.memory != null
	lims.cpu != null
	lims.memory != null
}
