package kubernetes.pod_security

import rego.v1

test_denies_missing_run_as_non_root if {
	count(deny) > 0 with input as {
		"kind": "Deployment",
		"metadata": {"name": "insecure-app"},
		"spec": {
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": false},
				},
			},
		},
	}
}

test_allows_run_as_non_root if {
	count(deny) == 0 with input as {
		"kind": "Deployment",
		"metadata": {"name": "hardened-app"},
		"spec": {
			"template": {
				"spec": {
					"securityContext": {"runAsNonRoot": true},
				},
			},
		},
	}
}
