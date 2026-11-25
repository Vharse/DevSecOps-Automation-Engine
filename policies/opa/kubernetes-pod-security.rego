package kubernetes.pod_security

import rego.v1

deny contains msg if {
	input.kind == "Deployment"
	not input.spec.template.spec.securityContext.runAsNonRoot
	msg := sprintf("Deployment '%s' must set spec.template.spec.securityContext.runAsNonRoot to true", [input.metadata.name])
}
